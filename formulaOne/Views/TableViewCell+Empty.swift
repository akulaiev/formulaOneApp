//
//  TableViewCell+Empty.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 31.01.2021.
//

import Foundation
import UIKit

extension UITableViewCell {
    func empty() -> UITableViewCell {
        self.textLabel?.text = ""
        self.detailTextLabel?.text = ""
        return self
    }
}
