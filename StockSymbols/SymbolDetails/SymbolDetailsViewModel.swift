//
//  SymbolDetailsViewModel.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine

protocol SymbolDetailsViewModel {
    
    var symbol: String { get }
    
    var symbolData: PassthroughSubject<StockDataProcessed, Never> { get }
    var symbolDataLoadingError: PassthroughSubject<Error, Never> { get }
    var selectedRange: CurrentValueSubject<StockRange, Never> { get }
    func loadData()
}

class SymbolDetailsViewModelForProd: SymbolDetailsViewModel {
    
    let symbol: String
    
    var symbolData: PassthroughSubject<StockDataProcessed, Never> = PassthroughSubject()
    var symbolDataLoadingError: PassthroughSubject<Error, Never> = PassthroughSubject()
    var selectedRange: CurrentValueSubject<StockRange, Never> = CurrentValueSubject(.oneDay)
    
    private let connectivityManager: ConnectivityManager
    
    private var stockInfoCancellable: AnyCancellable?
    private var rangeCancellable: AnyCancellable?
    private var isConnectedCancellable: AnyCancellable?
    
    private var isLoadingFailedDueToInternedConnection = false
    
    init(symbol: String, connectivityManager: ConnectivityManager = ReachabilityManager()) {
        self.symbol = symbol
        self.connectivityManager = connectivityManager
        
        rangeCancellable = selectedRange.dropFirst().removeDuplicates().sink { [weak self] range in
            guard let self = self else { return }
            self.loadData()
        }
        
        isConnectedCancellable = connectivityManager.isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] isConnected in
                guard let self = self else { return }
                
                if isConnected {
                    if self.isLoadingFailedDueToInternedConnection {
                        self.loadData()
                    }
                }
                
        })
    }
    
    func loadData() {
        guard connectivityManager.isConnected.value else {
            isLoadingFailedDueToInternedConnection = true
            symbolDataLoadingError.send(NetworkError.noInternetConnection)
            return
        }
        
        isLoadingFailedDueToInternedConnection = false
        let networkingService = StockInfoNetworkingService(symbol: symbol, range: selectedRange.value)
        do {
            stockInfoCancellable = try networkingService.loadSymbolInfo().sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    let nsError = error as NSError
                    let noInternetConnectionCode = -1009
                    if nsError.code == noInternetConnectionCode {
                        self.isLoadingFailedDueToInternedConnection = true
                    }
                    self.symbolDataLoadingError.send(error)
                case .finished:
                    self.stockInfoCancellable?.cancel()
                }
            }, receiveValue: { [weak self] symbolData in
                guard let self = self else { return }
                if let symbolData = StockDataProcessed(stock: symbolData) {
                    self.symbolData.send(symbolData)
                } else {
                    if let error = symbolData.spark.error {
                        self.symbolDataLoadingError.send(error)
                    } else {
                        self.symbolDataLoadingError.send(NetworkError.noDataAvailable)
                    }
                }
            })
        } catch {
            self.symbolDataLoadingError.send(error)
        }
       
    }
    
}
