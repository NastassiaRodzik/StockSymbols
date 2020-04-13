//
//  SymbolsListService.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine

protocol SymbolsListNetworkingClient {
    func loadSymbols(_ count: Int) throws -> AnyPublisher<Symbols, Error>
}

struct SymbolsListNetworkingService: NetworkingService, SymbolsListNetworkingClient {
    
    var router: NetworkRouter
    var session: URLSession
    
    init(symbolsCount: Int) {
        self.router = SymbolsRouter(symbolsCount: symbolsCount)
        self.session = URLSession.shared
    }
    
    func loadSymbols(_ count: Int) throws -> AnyPublisher<Symbols, Error> {
        do {
            let cancellable: AnyPublisher<Symbols, Error> = try loadDataWithCombine()
            return cancellable
        } catch {
            throw error
        }
    }
}
