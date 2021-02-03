//
//  DataManager.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

//Data structure with pagination info
struct PaginationParams {
    var totalCount: Int
    var dataCount: Int
    var requestOffset: Int
    
    mutating func update(totalCount: Int, requestOffset: Int, dataCount: Int) {
        self.totalCount = totalCount
        self.requestOffset += requestOffset
        self.dataCount += dataCount
    }
    
    static func empty() -> PaginationParams {
        return PaginationParams(totalCount: 0,
                                dataCount: 0, requestOffset: 0)
    }
}

protocol DataManagerDelegate: class {
    var paginationParams: PaginationParams { get set }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell
    func selectedRow(in tableView: UITableView, at indexPath: IndexPath)
    func updatePaginationParams(with data: Codable, total: Int, calculateReloadIndexPath: Bool) -> [IndexPath]?
}

class DataManager: NSObject {
    private var tableView: UITableView!
    private var cellIdentifier = ""
    private var isFetchInProgress = false
    
    let networkManager = NetworkManager(requestLimit: 13)
    weak var delegate: DataManagerDelegate!
    
    init(delegate: DataManagerDelegate, tableView: UITableView, cellIdentifier: String) {
        super.init()
        self.delegate = delegate
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.test()
    }
    
    fileprivate func test() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func fetchData<T: Codable>(for request: Request, type: T.Type, completion: @escaping (Result<([T], [IndexPath]?), Error>) -> Void) {
        if isFetchInProgress { return }
        isFetchInProgress = true
        networkManager.performRequest(request: request, requestOffset: self.delegate.paginationParams.requestOffset) { [self] (result: Result<APIResponse<T>, Error>) in
            isFetchInProgress = false
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(response):
                let indexPathsToReload = delegate.updatePaginationParams(with: response.data.result.results, total: Int(response.data.total) ?? 0, calculateReloadIndexPath: self.delegate.paginationParams.requestOffset >= Int(response.data.limit)!)
                completion(.success((response.data.result.results, indexPathsToReload)))
            }
        }
    }
    
    //MARK: - Pagination methods
    func calculateIndexPathsToReload(from newDataCount: Int, allDataCount: Int) -> [IndexPath] {
        let startIndex = allDataCount - newDataCount
        let endIndex = startIndex + newDataCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func visibleIndexPathsToReload(indexPaths: [IndexPath], tableView: UITableView) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= delegate.paginationParams.dataCount
    }

    //MARK: - Configuring of data representative table view
    func configureCell(_ cell: UITableViewCell) {
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 2.5
    }
    
    func clear(tableView: UITableView) {
        tableView.reloadData()
        delegate.paginationParams = PaginationParams.empty()
    }
}

// MARK: - Table view data source
extension DataManager: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.paginationParams.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell)
        return delegate!.configure(cell: cell, with: indexPath)
    }
}
