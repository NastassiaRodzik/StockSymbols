//
//  SymbolsRouter.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

private enum Parameter {
    static let count = "count"
}

struct SymbolsRouter: NetworkRouter {
    var method: HTTPMethod = .get
    var urlString: String = "https://query2.finance.yahoo.com/v1/finance/trending/US"
    let headers: [String: String] = [:]
    var parameters: [String : String?]
    
    init(symbolsCount: Int) {
        self.parameters = [Parameter.count: "\(symbolsCount)"]
    }
}
