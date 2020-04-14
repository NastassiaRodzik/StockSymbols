//
//  SymbolDataProcessed.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/14/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

struct ChartData {
    let x: [TimeInterval]
    let y: [Double]
}

struct StockParameter {
    let title: String
    let value: String
}

extension StockParameter {
    init(title: String, value: Double) {
        self.title = title
        self.value = String(format: "%.2f", value)
    }
}

struct StockDataProcessed {
    
    let symbol: String
    let parameters: [StockParameter]
    let chartData: ChartData?
    
    init(symbol: String) {
        self.symbol = symbol
        self.parameters = []
        self.chartData = nil
    }
    
    init?(stock: Stock) {
        guard let result = stock.spark.result.first else { return nil }
        self.symbol = result.symbol
        
        guard let response = result.response.first else {
            self.parameters = []
            self.chartData = nil
            return
        }
        
        if let closeData = response.indicators.quote.first?.close {
            let timeData = response.timestamp
            chartData = ChartData(x: timeData, y: closeData)
        } else {
            chartData = nil
        }
        
        
        var symbolParametersMutable: [StockParameter] = []
        
        let meta = response.meta
        symbolParametersMutable.append(StockParameter(title: "Currency", value: meta.currency))
        symbolParametersMutable.append(StockParameter(title: "Exchange Name", value: meta.exchangeName))
        symbolParametersMutable.append(StockParameter(title: "Instrument Type", value: meta.instrumentType))
        symbolParametersMutable.append(StockParameter(title: "Regular Market Price", value: meta.regularMarketPrice))
        symbolParametersMutable.append(StockParameter(title: "Previous Close", value: meta.previousClose))
        
        self.parameters = symbolParametersMutable
    }
    
}
