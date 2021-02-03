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
    
    private weak var yearPicker: UIPickerView!
    private weak var placePicker: UIPickerView!
    private weak var yearPickerButton: UIButton!
    private weak var placePickerButton: UIButton!
    private var pickedYear = ""
    private var pickedPlace = ""
    
    init(tableView: UITableView, delegate: ViewModelDelegate, request: Request, pickerViews: [UIPickerView], pickerButtons: [UIButton]) {
        super.init(tableView: tableView, delegate: delegate, request: request)
        yearPicker = pickerViews[0]
        placePicker = pickerViews[1]
        yearPickerButton = pickerButtons[0]
        placePickerButton = pickerButtons[1]
        yearPicker.tag = 10
        placePicker.tag = 20
    }
    
    required init(tableView: UITableView, delegate: ViewModelDelegate, request: Request) {
        fatalError("init(tableView:delegate:request:) has not been implemented")
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
            self.yearPicker.delegate = self
            self.yearPicker.dataSource = self
            self.placePicker.delegate = self
            self.placePicker.dataSource = self
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
            return seasonsData.count
        } else {
            return 24
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 10 {
            return seasonsData[row].season
        }
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 10 {
            pickedYear = seasonsData[row].season
            yearPickerButton.setTitle(pickedYear + " ▼", for: .normal)
        } else {
            pickedPlace = String(row + 1)
            placePickerButton.setTitle(pickedPlace + " ▼", for: .normal)
        }
        pickerView.isHidden = true
        if !pickedYear.isEmpty && !pickedPlace.isEmpty {
            clear(tableView: tableView)
            tableView.isHidden = false
            request = Request.pastRaces(year: pickedYear, place: pickedPlace)
            fetchData()
        }
    }
}
