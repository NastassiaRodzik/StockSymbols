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
    var symbolData: PassthroughSubject<SymbolDataProcessed, Error> { get }
    func loadData()
}

class SymbolDetailsViewModelForProd: SymbolDetailsViewModel {
    
    var symbolData: PassthroughSubject<SymbolDataProcessed, Error> = PassthroughSubject()
    
    private let symbol: String
    private var cancellable: AnyCancellable?
    
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    func loadData() {
        let networkingService = SymbolInfoNetworkingService(symbol: symbol)
        do {
            cancellable = try networkingService.loadSymbolInfo().sink(receiveCompletion: { (completion) in
                print(completion)
            }, receiveValue: { [weak self] symbolData in
                guard let self = self else { return }
                if let symbolData = SymbolDataProcessed(symbolData: symbolData) {
                    self.symbolData.send(symbolData)
                } else {
                    self.symbolData.send(SymbolDataProcessed(symbol: self.symbol))
                }
            })
        } catch {
            print("error catched \(error)")
        }
       
    }
    
}
