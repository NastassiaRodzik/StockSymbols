//
//  NetworkRouter.swift
//  ItemsLoader
//
//  Created by Анастасия Ковалева on 4/7/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRouter {
    var method: HTTPMethod { get }
    var urlString: String { get }
    var headers: [String: String] { get }
    var parameters: [String: String?] { get }
}

extension NetworkRouter {
    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: urlString) else {
            throw NetworkError.invalidURL
        }
        let queryItems: [URLQueryItem] = parameters.map({ URLQueryItem(name: $0.key, value: $0.value) })
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        headers.forEach { (headerTitle, headerValue) in
            request.addValue(headerValue, forHTTPHeaderField: headerTitle)
        }
        return request
    }
}
