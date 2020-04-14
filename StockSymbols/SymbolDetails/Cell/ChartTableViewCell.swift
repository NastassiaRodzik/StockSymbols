//
//  ChartTableViewCell.swift
//  StockSymbols
//
//  Created by Анастасия Ковалева on 4/14/20.
//  Copyright © 2020 Anastasia Rodzik. All rights reserved.
//

import UIKit
import Charts

final class ChartTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var chartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureChartView()
    }
    
    func configure(with chartData: ChartData?) {
        guard let chartData = chartData else { return }
        
        var entries : [ChartDataEntry] = [ChartDataEntry]()
        for chartItem in zip(chartData.x, chartData.y) {
            entries.append(ChartDataEntry(x: chartItem.0, y: chartItem.1))
        }
        
        let chartDataSet = LineChartDataSet(entries: entries, label: "Close Price")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.mode = .horizontalBezier
        chartDataSet.drawValuesEnabled = false
        
        chartDataSet.valueFormatter = DefaultValueFormatter(decimals: 2)
        let lineChartData = LineChartData(dataSets: [chartDataSet])
        chartView.data = lineChartData
    }
    
    private func configureChartView() {
        chartView.isUserInteractionEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawLabelsEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.labelTextColor = UIColor.gray
        chartView.leftAxis.labelTextColor = UIColor.gray
    }
    
}
