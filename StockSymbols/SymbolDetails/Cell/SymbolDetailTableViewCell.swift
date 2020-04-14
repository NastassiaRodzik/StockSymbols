//
//  SymbolDetailTableViewCell.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/14/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit

class SymbolDetailTableViewCell: UITableViewCell {

    static let rowHeight: CGFloat = 70
    
    @IBOutlet private weak var parameterTitleLabel: UILabel!
    @IBOutlet private weak var parameterValueLabel: UILabel!
    
    func configure(with symbolParameter: SymbolParameter) {
        parameterTitleLabel.text = symbolParameter.title
        parameterValueLabel.text = symbolParameter.value
    }
    
}
