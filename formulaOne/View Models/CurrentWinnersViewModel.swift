//
//  CurrentWinnersViewModel.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 29.01.2021.
//

import Foundation
import UIKit

class CurrentWinnersViewModel: BaseViewModel<Race> {
    override func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if dataManager.isLoadingCell(for: indexPath) == false {
            let dataEntry = data[indexPath.row]
            cell.textLabel?.text = dataEntry.resultsInfo[0].driver.familyName + " " + dataEntry.resultsInfo[0].driver.givenName + " " + dataEntry.resultsInfo[0].number
            cell.detailTextLabel?.text = dataEntry.raceName
        }
        return cell
    }
}
