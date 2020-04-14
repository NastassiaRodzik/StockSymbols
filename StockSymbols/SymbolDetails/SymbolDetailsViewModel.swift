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
    var symbolData: PassthroughSubject<StockDataProcessed, Never> { get }
    var symbolDataLoadingError: PassthroughSubject<Error, Never> { get }
    var selectedRange: CurrentValueSubject<StockRange, Never> { get }
    func loadData()
}

class SymbolDetailsViewModelForProd: SymbolDetailsViewModel {
    
    var symbolData: PassthroughSubject<StockDataProcessed, Never> = PassthroughSubject()
    var symbolDataLoadingError: PassthroughSubject<Error, Never> = PassthroughSubject()
    var selectedRange: CurrentValueSubject<StockRange, Never> = CurrentValueSubject(.oneDay)
    
    private let symbol: String
    
    private var stockInfoCancellable: AnyCancellable?
    private var rangeCancellable: AnyCancellable?
    
    init(symbol: String) {
        self.symbol = symbol
        
        rangeCancellable = selectedRange.dropFirst().removeDuplicates().sink { [weak self] range in
            guard let self = self else { return }
            self.loadData()
        }
    }
    
    func loadData() {
        let networkingService = StockInfoNetworkingService(symbol: symbol, range: selectedRange.value)
        do {
            stockInfoCancellable = try networkingService.loadSymbolInfo().sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
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
                        self.symbolData.send(StockDataProcessed(symbol: self.symbol))
                    }
                    
                }
            })
        } catch {
            self.symbolDataLoadingError.send(error)
        }
       
    }
    
}
