//
//  UIViewController.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/14/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showNetworkError( _ error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Cannot load data", comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                     style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}
