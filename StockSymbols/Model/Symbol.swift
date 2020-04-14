//
//  Symbol.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

struct Symbol: Codable {
    let spark: Spark
}

struct Spark: Codable {
    let result: [Result]
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
    let firstTradeDate: TimeInterval
    let regularMarketTime: TimeInterval
    let gmtoffset: TimeInterval
    let timezone: String
    let exchangeTimezoneName: String
    let regularMarketPrice: Double
    let chartPreviousClose: Double
    let previousClose: Double
    let scale: Int
    let priceHint: Int
    //currentTradingPeriod
    //tradingPeriods
    let dataGranularity: String
    let range: String
    let validRanges: [String]
   

}

struct Indicator: Codable {
    let quote: [SymbolQuote]
}

struct SymbolQuote: Codable {
    let close: [Double]
}
