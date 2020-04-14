//
//  SymbolRoute.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

private enum Parameter {
    static let range = "range"
    static let symbol = "symbols"
}

struct SymbolRoute: NetworkRouter {
    var method: HTTPMethod = .get
    var urlString: String = "https://query1.finance.yahoo.com/v7/finance/spark"
    let headers: [String: String] = [:]
    var parameters: [String : String?]
    
    init(symbol: String) {
        //symbols=^DJI&range=1d
        self.parameters = [Parameter.symbol: symbol,
                           Parameter.range: "1d"]
    }
}
