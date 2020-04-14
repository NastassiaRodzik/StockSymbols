//
//  SymbolDetailsViewController.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit
import Combine
import DropDown

class SymbolDetailsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var selectRangeButton: UIButton!
    
    private let viewModel: SymbolDetailsViewModel
    private var possibleRangesCached: [StockRange] = []
    private var symbolData: StockDataProcessed? {
        didSet {
            if let symbolData = symbolData {
                possibleRangesCached = symbolData.possibleRanges
                self.title = symbolData.symbol
            }
            tableView.reloadData()
        }
    }
    
    private var symbolDataCancellable: AnyCancellable?
    private var symbolErrorCancellable: AnyCancellable?
    
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
        
        self.selectRangeButton.setTitle(viewModel.selectedRange.value.localizedDescription, for: .normal)
        
        symbolDataCancellable = viewModel.symbolData.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] stock in
            guard let self = self else { return }
            self.symbolData = stock
        })
        symbolErrorCancellable = viewModel.symbolDataLoadingError.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] error in
            guard let self = self else { return }
            self.showNetworkError(error)
            self.symbolData = nil
        })
    }
    
    @IBAction func selectRangeButtonDidTap(_ sender: Any) {
        guard !possibleRangesCached.isEmpty else { return }
        let dropDown = DropDown()
        dropDown.anchorView = selectRangeButton
        dropDown.dataSource = possibleRangesCached.compactMap({ $0.localizedDescription })
        let dropDownWidth: CGFloat = 200
        dropDown.width = dropDownWidth
        dropDown.dismissMode = .onTap
        dropDown.direction = .bottom
        dropDown.backgroundColor = .white
        dropDown.cornerRadius = 20.0
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let selectedRange = self.possibleRangesCached[index]
            self.viewModel.selectedRange.send(selectedRange)
            self.selectRangeButton.setTitle(selectedRange.localizedDescription, for: .normal)
            dropDown.hide()
        }
        dropDown.bottomOffset = CGPoint(x: 0, y: (3/4)*selectRangeButton.frame.height)
        dropDown.show()
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
