//
//  SymbolTableViewCell.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit

class SymbolTableViewCell: UITableViewCell {
    
    static let rowHeight: CGFloat = 80
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    func configure(with symbolName: String?) {
        nameLabel.text = symbolName
    }
    
}
