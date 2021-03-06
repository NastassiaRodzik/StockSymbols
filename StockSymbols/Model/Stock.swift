//
//  Stock.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

struct Stock: Codable {
    let spark: Spark
}

struct Spark: Codable {
    let result: [Result]?
    let error: SparkError?
}

struct Result: Codable {
    let symbol: String
    let response: [Response]
}

struct Response: Codable {
    let meta: Meta
    let timestamp: [TimeInterval]
    let indicators: Indicator
}

struct Meta: Codable {
    let currency: String
    let symbol: String
    let exchangeName: String
    let instrumentType: String
    let regularMarketPrice: Double
    let previousClose: Double?
    let validRanges: [String]
}

struct Indicator: Codable {
    let quote: [SymbolQuote]
}

struct SymbolQuote: Codable {
    let close: [Double]
}

struct SparkError: Error, Codable {
    let code: String?
    let description: String?
}
