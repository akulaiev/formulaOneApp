//
//  BaseViewModel.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 31.01.2021.
//

import Foundation
import UIKit

protocol ViewModelDelegate: class {
    var cellIdentifier: String { get }
    var notificationName: NSNotification.Name { get }
}

class BaseViewModel<T>: NSObject, DataManagerDelegate, UITableViewDataSourcePrefetching where T: Codable {
    let tableView: UITableView!
    weak var delegateViewController: ViewModelDelegate!
    var request: Request!
    var dataManager: DataManager!
    var data = [T]()
    var paginationParams = PaginationParams.empty()
    
    required init(tableView: UITableView, delegate: ViewModelDelegate, request: Request) {
        self.tableView = tableView
        self.delegateViewController = delegate
        self.request = request
        super.init()
        self.tableView.prefetchDataSource = self
    }
    
    func fetchData() {
        dataManager.fetchData(for: request, type: T.self) { [self] result in
            switch result {
            case let .success((fetchedData, indexPaths)):
                data.append(contentsOf: fetchedData)
                onFetchCompleted(with: indexPaths)
            case let .failure(error):
                onFetchFailed(with: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Data Manager Delegate implementation
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.reloadData()
            return
        }
        let indexPathsToReload = dataManager.visibleIndexPathsToReload(indexPaths: newIndexPathsToReload, tableView: tableView)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        HelperMethods.showFailureAlert(title: "Warning", message: reason, controller: delegateViewController as? UIViewController)
    }
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        return cell.empty()
    }
    
    func selectedRow(in tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: delegateViewController.notificationName, object: self, userInfo: ["selectedRow": indexPath.row])
    }
    
    func updatePaginationParams(with data: Codable, total: Int, calculateReloadIndexPath: Bool) -> [IndexPath]? {
        let resultData = data as! [Race]
        paginationParams.update(totalCount: total, requestOffset: resultData.count, dataCount: resultData.count)
        if calculateReloadIndexPath {
            let indexPathsToReload = dataManager.calculateIndexPathsToReload(from: resultData.count, allDataCount: paginationParams.dataCount)
            return indexPathsToReload
        }
        return nil
    }
    
    //MARK: - UITableViewDataSourcePrefetching Delegate
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
     if indexPaths.contains(where: dataManager.isLoadingCell) {
         fetchData()
        }
    }
}