//
//  UIPickerView+ManageState.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 02.02.2021.
//

import Foundation
import UIKit

extension UIPickerView {
    func manageState(showPickerView: Bool, tableView: UITableView) {
        isHidden = !showPickerView
        tableView.isHidden = showPickerView
    }
}
