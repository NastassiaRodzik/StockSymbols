//
//  StockRange.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/14/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

enum StockRange: String {
    case oneDay = "1d"
    case fiveDays = "5d"
    case oneMonth = "1mo"
    case threeMonths = "3mo"
    case max
}

extension StockRange {
    var localizedDescription: String {
        switch self {
        case .oneDay:
            return NSLocalizedString("1 Day", comment: "")
        case .fiveDays:
            return NSLocalizedString("5 Days", comment: "")
        case .oneMonth:
            return NSLocalizedString("1 Month", comment: "")
        case .threeMonths:
            return NSLocalizedString("3 Months", comment: "")
        case .max:
            return NSLocalizedString("Max", comment: "")
        }
    }
}
