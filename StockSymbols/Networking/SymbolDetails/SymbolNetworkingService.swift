//
//  SymbolNetworkingService.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine

protocol StockNetworkingClient {
    func loadSymbolInfo() throws -> AnyPublisher<Stock, Error>
}

struct StockInfoNetworkingService: NetworkingService, StockNetworkingClient {
    
    var router: NetworkRouter
    var session: URLSession
    
    init(symbol: String, range: StockRange) {
        self.router = StockRoute(symbol: symbol, range: range)
        self.session = URLSession.shared
    }
    
    func loadSymbolInfo() throws -> AnyPublisher<Stock, Error> {
        do {
            let cancellable: AnyPublisher<Stock, Error> = try loadDataWithCombine()
            return cancellable
        } catch {
            throw error
        }
    }
    
}
