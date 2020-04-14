//
//  SymbolsListViewController.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/13/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit
import Combine

class SymbolsListViewController: UIViewController {

    @IBOutlet private weak var symbolsTable: UITableView!
    @IBOutlet private weak var symbolsNumberTextField: UITextField!
    
    private let symbolsNumberPicker = UIPickerView()
    private let pickerToolbar = UIToolbar()
    
    private var symbols: [String] = [] {
        didSet {
            symbolsTable.reloadData()
        }
    }
    private let viewModel: SymbolsListViewModel
    private var symbolsCancellable: AnyCancellable?
    
    private let maxSymbolsNumber: Int = 40
    
    init(viewModel: SymbolsListViewModel = SymbolsListViewModelForProd()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface()
        symbolsCancellable = viewModel.symbolsPublisher.sink(receiveCompletion: { completion in
            // TODO: show error if needed
            print(completion)
        }) { [weak self] symbols in
            self?.symbols = symbols
        }
        viewModel.loadSymbols()
    }
    
    @objc private func doneButtonDidTap() {
        symbolsNumberTextField.resignFirstResponder()
    }

}

// MARK: - Interface Configuration

private extension SymbolsListViewController {
    
    func configureInterface() {
        configureTable()
        configureTextField()
        self.title = NSLocalizedString("Stock Symbols", comment: "")
    }
    
    func configureTextField() {
        symbolsNumberTextField.inputView = symbolsNumberPicker
        symbolsNumberPicker.dataSource = self
        symbolsNumberPicker.delegate = self
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTap))
        pickerToolbar.setItems([doneButton], animated: false)
        pickerToolbar.autoresizingMask = .flexibleHeight
        symbolsNumberTextField.inputAccessoryView = pickerToolbar
        symbolsNumberTextField.delegate = self
        
    }
    
    func configureTable() {
        symbolsTable.register(UINib(nibName: SymbolTableViewCell.identifier, bundle: nil),
                              forCellReuseIdentifier: SymbolTableViewCell.identifier)
        symbolsTable.rowHeight = SymbolTableViewCell.rowHeight
        symbolsTable.dataSource = self
        symbolsTable.delegate = self
        symbolsTable.keyboardDismissMode = .onDrag
    }
    
}

// MARK: - UITextFieldDelegate

extension SymbolsListViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        symbolsNumberPicker.selectRow(viewModel.symbolsCountPublisher.value - 1, inComponent: 0, animated: false)
        return true
    }
}

// MARK: - UITableViewDataSource
extension SymbolsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SymbolTableViewCell.identifier) as! SymbolTableViewCell
        let currentSymbol = symbols[indexPath.row]
        cell.configure(with: currentSymbol)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SymbolsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symbol = symbols[indexPath.row]
        print("did select \(symbol)")
        let viewModel = SymbolDetailsViewModelForProd(symbol: symbol)
        let viewControllerToPresent = SymbolDetailsViewController(viewModel: viewModel)
//        present(viewControllerToPresent, animated: true, completion: nil)
        navigationController?.pushViewController(viewControllerToPresent, animated: true)
    }
}

// MARK: - UIPickerViewDataSource
extension SymbolsListViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxSymbolsNumber
    }
}

// MARK: - UIPickerViewDelegate
extension SymbolsListViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let symbolsNumber = row + 1
        symbolsNumberTextField.text = "\(symbolsNumber)"
        viewModel.symbolsCountPublisher.send(symbolsNumber)
    }
}

