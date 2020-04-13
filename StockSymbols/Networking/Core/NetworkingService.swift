//
//  NetworkingService.swift
//  ItemsLoader
//
//  Created by Anastasia Rodzik on 20.02.2020.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine

protocol NetworkingService {
    var router: NetworkRouter { get }
    var session: URLSession { get }
    
    func loadDataWithCombine<T: Decodable>() throws -> AnyPublisher<T, Error>
}

extension NetworkingService {
    func loadDataWithCombine<T: Decodable>() throws -> AnyPublisher<T, Error> {
        do {
            let request = try router.asURLRequest()
            let cancellable = session.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let response = response as? HTTPURLResponse,
                        200...299 ~= response.statusCode else {
                            if let badStatusCodeError = try? JSONDecoder().decode(BadStatusCodeError.self, from: data) {
                                throw badStatusCodeError
                            }
                            throw NetworkError.invalidResponse
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
            return cancellable
        } catch {
            throw error
        }
        
    }
}
