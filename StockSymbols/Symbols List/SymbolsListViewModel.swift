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
    var symbolsPublisher: PassthroughSubject<[String], Error> { get }
    func loadSymbols()
}

class SymbolsListViewModelForProd: SymbolsListViewModel {
    
    let symbolsPublisher: PassthroughSubject<[String], Error> = PassthroughSubject()
    let symbolsCountPublisher: CurrentValueSubject<Int, Never> = CurrentValueSubject(Constants.defaultSumbolsNumber)
   
    private var sumbolsCancellable: AnyCancellable?
    private var symbolsCountStringCancellable: AnyCancellable?
    
    init() {
        symbolsCountStringCancellable = symbolsCountPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { symbolsCount in
                self.loadSymbols(symbolsCount)
        }
    }
    
    func loadSymbols() {
        loadSymbols(symbolsCountPublisher.value)
    }
    
    private func loadSymbols(_ symbolsNumber: Int) {
        do {
            let networkingClient = SymbolsListNetworkingService(symbolsCount: symbolsNumber)
            sumbolsCancellable = try networkingClient.loadSymbols(symbolsNumber).receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    print("Error \(error)")
                case .finished:
                    self.sumbolsCancellable?.cancel()
                }
            }) { [weak self] symbols in
                guard let self = self else { return }
                guard let result = symbols.finance.result.first else {
                    print("empty result")
                    return
                }
                let symbolsValue = result.quotes.compactMap({ $0.symbol })
                self.symbolsPublisher.send(symbolsValue)
            }
        } catch {
            print("catched error")
            print(error)
//            symbolsPublisher.send(completion: Subscriber.Failure(error))
        }
        
    }
}
