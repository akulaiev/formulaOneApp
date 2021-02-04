//
//  RaceDetailsViewModel.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 30.01.2021.
//

import Foundation
import UIKit

class RaceDetailsViewModel: BaseViewModel<Race> {
    override func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if !dataManager.isLoadingCell(for: indexPath) {
            let dataEntry = data[0].resultsInfo[indexPath.row]
            cell.textLabel?.text = dataEntry.number + " " + dataEntry.driver.givenName + " " + dataEntry.driver.familyName
            cell.detailTextLabel?.text = dataEntry.time?.time ?? "Time unknown"
        }
        return cell
    }
    
    override func fetchData() {
        dataManager.fetchData(for: request, type: Race.self) { [self] result in
            switch result {
            case let .success((fetchedData, indexPaths)):
                if data.count > 0 {
                    data[0].resultsInfo.append(contentsOf: fetchedData[0].resultsInfo)
                }
                else {
                    data = fetchedData
                }
                onFetchCompleted(with: indexPaths)
            case let .failure(error):
                onFetchFailed(with: error.localizedDescription)
            }
        }
    }
}
