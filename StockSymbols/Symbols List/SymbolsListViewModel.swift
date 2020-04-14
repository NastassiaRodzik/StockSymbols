//
//  SymbolsListViewModel.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine

private enum Constants {
    static let defaultSumbolsNumber = 20
}

protocol SymbolsListViewModel {
    var symbolsCountPublisher: CurrentValueSubject<Int, Never> { get }
    var symbolsPublisher: PassthroughSubject<[String], Never> { get }
    var symbolsLoadingErrorPublisher: PassthroughSubject<Error, Never> { get }
    func loadSymbols()
}

final class SymbolsListViewModelForProd: SymbolsListViewModel {
    
    let symbolsPublisher: PassthroughSubject<[String], Never> = PassthroughSubject()
    var symbolsLoadingErrorPublisher: PassthroughSubject<Error, Never> = PassthroughSubject()
    let symbolsCountPublisher: CurrentValueSubject<Int, Never> = CurrentValueSubject(Constants.defaultSumbolsNumber)
   
    private let connectivityManager: ConnectivityManager
    
    private var sumbolsCancellable: AnyCancellable?
    private var symbolsCountStringCancellable: AnyCancellable?
    private var isConnectedCancellable: AnyCancellable?
    
    private var isLoadingFailedDueToInternedConnection = false
    
    init(connectivityManager: ConnectivityManager = ReachabilityManager()) {
        self.connectivityManager = connectivityManager
        
        symbolsCountStringCancellable = symbolsCountPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { symbolsCount in
                self.loadSymbols(symbolsCount)
        }
        
        isConnectedCancellable = connectivityManager.isConnected
            .removeDuplicates()
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] isConnected in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if isConnected {
                        if self.isLoadingFailedDueToInternedConnection {
                            self.loadSymbols()
                        }
                    }
                }
        })
    }
    
    func loadSymbols() {
        loadSymbols(symbolsCountPublisher.value)
    }
    
    private func loadSymbols(_ symbolsNumber: Int) {
        guard connectivityManager.isConnected.value else {
            isLoadingFailedDueToInternedConnection = true
            symbolsLoadingErrorPublisher.send(NetworkError.noInternetConnection)
            return
        }
        
        isLoadingFailedDueToInternedConnection = false
        
        do {
            let networkingClient = SymbolsListNetworkingService(symbolsCount: symbolsNumber)
            sumbolsCancellable = try networkingClient.loadSymbols(symbolsNumber)
                .sink(receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        switch completion {
                        case .failure(let error):
                            let nsError = error as NSError
                            let noInternetConnectionCode = -1009
                            if nsError.code == noInternetConnectionCode {
                                self.isLoadingFailedDueToInternedConnection = true
                            }
                            self.symbolsLoadingErrorPublisher.send(error)
                        case .finished:
                            self.sumbolsCancellable?.cancel()
                        }
                    }
                
            }) { [weak self] symbols in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    guard let result = symbols.finance.result.first else {
                        self.symbolsLoadingErrorPublisher.send(NetworkError.noDataAvailable)
                        return
                    }
                    let symbolsValue = result.quotes.compactMap({ $0.symbol })
                    self.symbolsPublisher.send(symbolsValue)
                }
            }
        } catch {
            symbolsLoadingErrorPublisher.send(error)
        }
        
    }
}
