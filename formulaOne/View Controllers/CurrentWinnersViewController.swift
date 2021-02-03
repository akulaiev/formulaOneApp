//
//  CurrentWinnersViewController.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 29.01.2021.
//

import UIKit

class CurrentWinnersViewController: UITableViewController, ViewModelDelegate {
    var viewModel: CurrentWinnersViewModel!
    let cellIdentifier = "currentWinnersCell"
    let notificationName = NSNotification.Name("CurrentWinnersCellSelected")
    
    private let segueIdentifier = "toResults"
    private var observer: Any!
    private var selectedRace: Race!
    
    deinit {
        NotificationCenter.default.removeObserver(observer!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataModel()
    }
    
    fileprivate func setupDataModel() {
        viewModel = CurrentWinnersViewModel(tableView: tableView, delegate: self, request: Request.currentWinners)
        viewModel.dataManager = DataManager(delegate: viewModel, tableView: tableView, cellIdentifier: cellIdentifier)
        viewModel.fetchData()
        listenForSelectedCellNotifications()
    }
    
    func listenForSelectedCellNotifications() {
        observer = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { notification in
            guard let selectedRow = notification.userInfo?["selectedRow"] as? Int else { return }
            self.selectedRace = self.viewModel.data[selectedRow]
            self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let vc = segue.destination as! RaceDetailsViewController
            guard let selectedRace = selectedRace else { return }
            vc.race = selectedRace
        }
    }
}
