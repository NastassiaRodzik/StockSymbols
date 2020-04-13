//
//  Symbols.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

struct Symbols: Codable {
    let finance: Finance
}

struct Finance: Codable {
    let result: [SymbolsResult]
}

struct SymbolsResult: Codable {
    let quotes: [Quote]
}

struct Quote: Codable {
    let symbol: String
}
