//
//  PastRacesViewModel.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 01.02.2021.
//

import Foundation
import UIKit

class PastRacesViewModel: BaseViewModel<Race> {
    var seasonsData = [Season]()
    
    private weak var yearPicker: UIPickerView?
    private weak var placePicker: UIPickerView?
    private weak var yearPickerButton: UIButton?
    private weak var placePickerButton: UIButton?
    private var pickedYear = ""
    private var pickedPlace = ""
    
    init(tableView: UITableView, cellIdentifier: String, delegate: ViewModelDelegate, request: Request, pickerViews: [UIPickerView], pickerButtons: [UIButton]) {
        super.init(tableView: tableView, delegate: delegate, request: request, dataManager: DataManager(cellIdentifier: cellIdentifier))
        yearPicker = pickerViews[0]
        placePicker = pickerViews[1]
        yearPickerButton = pickerButtons[0]
        placePickerButton = pickerButtons[1]
        yearPicker?.tag = 10
        placePicker?.tag = 20
    }
    
    required init(tableView: UITableView, delegate: ViewModelDelegate, request: Request, dataManager: DataManager?) {
        fatalError("init(tableView:delegate:request:dataManager:) has not been implemented")
    }
    
    fileprivate func fetchSeasonsData(completion: @escaping () -> Void) {
        var total = 0
        var offset = 0
        
        func recurringFetch() {
            if seasonsData.count == 0 || seasonsData.count < total {
                dataManager.networkManager.performRequest(request: Request.allSeasons, requestOffset: offset) { [self] (result: Result<APIResponse<Season>, Error>) in
                    switch result {
                    case let .failure(error):
                        onFetchFailed(with: error.localizedDescription)
                        return
                    case let .success(response):
                        seasonsData.append(contentsOf: response.data.result.results)
                        total = Int(response.data.total)!
                        offset += response.data.result.results.count
                        recurringFetch()
                    }
                }
            }
            else {
                completion()
            }
        }
        recurringFetch()
    }
    
    func configurePickersDelegates() {
        fetchSeasonsData {
            guard let yearPicker = self.yearPicker, let placePicker = self.placePicker else { return }
            yearPicker.delegate = self
            yearPicker.dataSource = self
            placePicker.delegate = self
            placePicker.dataSource = self
        }
    }
    
    override func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if !dataManager.isLoadingCell(for: indexPath) {
            let dataEntry = data[indexPath.row]
            cell.textLabel?.text = dataEntry.resultsInfo[0].driver.familyName + " " + dataEntry.resultsInfo[0].driver.givenName + " " + dataEntry.resultsInfo[0].number
            cell.detailTextLabel?.text = dataEntry.raceName
            return cell
        }
        return cell.empty()
    }
    
    func clear(tableView: UITableView) {
        data.removeAll()
        tableView.reloadData()
        paginationParams.requestOffset = 0
        paginationParams.totalCount = 0
        paginationParams.dataCount = 0
    }
    
    override func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        super.onFetchCompleted(with: newIndexPathsToReload)
        if paginationParams.totalCount == 0 {
            HelperMethods.showFailureAlert(title: "Oops!", message: "There are no drivers for picked parameters", controller: delegateViewController as? UIViewController)
        }
    }
}

extension PastRacesViewModel: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 10 {
            return seasonsData.count + 1
        } else {
            return 25
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 { return "" }
        if pickerView.tag == 10 {
            return seasonsData[seasonsData.count - row].season
        }
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 { return }
        if let yearPickerButton = yearPickerButton, pickerView.tag == 10 {
            pickedYear = seasonsData[seasonsData.count - row].season
            yearPickerButton.setTitle(pickedYear + " ▼", for: .normal)
        } else {
            if let placePickerButton = placePickerButton {
                pickedPlace = String(row)
                placePickerButton.setTitle(pickedPlace + " ▼", for: .normal)
            }
        }
        pickerView.isHidden = true
        if let tableView = tableView, !pickedYear.isEmpty && !pickedPlace.isEmpty {
            clear(tableView: tableView)
            tableView.isHidden = false
            request = Request.pastRaces(year: pickedYear, place: pickedPlace)
            fetchData()
        }
    }
}
