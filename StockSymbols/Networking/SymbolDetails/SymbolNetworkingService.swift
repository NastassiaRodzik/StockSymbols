//
//  SymbolNetworkingService.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine

protocol SymbolNetworkingClient {
    func loadSymbolInfo() throws -> AnyPublisher<Symbol, Error>
}

struct SymbolInfoNetworkingService: NetworkingService, SymbolNetworkingClient {
    
    var router: NetworkRouter
    var session: URLSession
    
    init(symbol: String) {
        self.router = SymbolRoute(symbol: symbol)
        self.session = URLSession.shared
    }
    
    func loadSymbolInfo() throws -> AnyPublisher<Symbol, Error> {
        do {
            let cancellable: AnyPublisher<Symbol, Error> = try loadDataWithCombine()
            return cancellable
        } catch {
            throw error
        }
    }
    
}
