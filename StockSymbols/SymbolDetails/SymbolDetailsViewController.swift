//
//  SymbolDetailsViewController.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit
import Combine
import Charts

class SymbolDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let viewModel: SymbolDetailsViewModel
    private var symbolData: SymbolDataProcessed? {
        didSet {
            self.title = symbolData?.symbol
            tableView.reloadData()
        }
    }
    
    private var symbolDataCancellable: AnyCancellable?
    
    init(viewModel: SymbolDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface()
        viewModel.loadData()
        symbolDataCancellable = viewModel.symbolData.receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            // TODO: show error if needed
            self.symbolDataCancellable?.cancel()
        }, receiveValue: { [weak self] symbolData in
            guard let self = self else { return }
            self.symbolData = symbolData
            self.symbolDataCancellable?.cancel()
        })
    }

}

// MARK: - UITableViewDataSource
extension SymbolDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let parametersCount = symbolData?.parameters.count ?? 0
        let chartsCount = symbolData?.chartData != nil ? 1 : 0
        return parametersCount + chartsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let parametersCount = symbolData?.parameters.count ?? 0
        let isChartCell = parametersCount == 0 || indexPath.row >= parametersCount
        
        if isChartCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCell.identifier) as! ChartTableViewCell
            cell.configure(with: symbolData?.chartData)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SymbolDetailTableViewCell.identifier) as! SymbolDetailTableViewCell
            let currentParameter = symbolData!.parameters[indexPath.row]
            cell.configure(with: currentParameter)
            return cell
        }
        
    }
    
    
}


// MARK: - Interface Configuration
private extension SymbolDetailsViewController {
    
    func configureInterface() {
        self.title = symbolData?.symbol
        configureTableView()
    }
    
    func configureTableView() {
        tableView.register(UINib(nibName: SymbolDetailTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: SymbolDetailTableViewCell.identifier)
        
        tableView.register(UINib(nibName: ChartTableViewCell.identifier, bundle: nil),
        forCellReuseIdentifier: ChartTableViewCell.identifier)
        tableView.estimatedRowHeight = SymbolDetailTableViewCell.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
    }
    
}
