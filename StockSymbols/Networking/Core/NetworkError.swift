//
//  NetworkError.swift
//  ItemsLoader
//
//  Created by Anastasia Rodzik on 21.02.2020.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noDataAvailable
    case invalidResponse
}

extension NetworkError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("URL you are trying to reach is invalid", comment: "")
        case .noDataAvailable:
            return NSLocalizedString("No data available for your request", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Server response is invalid. Please try again later", comment: "")
        }
    }
}

struct BadStatusCodeError: Error, Codable, LocalizedError {
    let message: String?
    
    var errorDescription: String? {
        return message
    }
}
