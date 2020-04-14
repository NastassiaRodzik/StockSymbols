//
//  Connectivity.swift
//  SeatGeekEvents
//
//  Created by Анастасия Ковалева on 4/14/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import Foundation
import Combine
import Reachability

protocol ConnectivityManager {
    
    var isConnected: CurrentValueSubject<Bool, Never> { get }
    
}

class ReachabilityManager: ConnectivityManager {
    var isConnected: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    
    private let reachability: Reachability
    
    deinit {
        reachability.stopNotifier()
    }
    
    init() {
        reachability = try! Reachability()

        reachability.whenReachable = { [weak self] _ in
            guard let self = self else { return }
            self.isConnected.send(true)
        }
        reachability.whenUnreachable = { [weak self] _ in
            guard let self = self else { return }
            self.isConnected.send(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
}
