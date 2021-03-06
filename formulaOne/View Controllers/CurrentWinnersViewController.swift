//
//  CurrentWinnersViewController.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 29.01.2021.
//

import UIKit

class CurrentWinnersViewController: UITableViewController, ViewModelDelegate {
    let cellIdentifier = "currentWinnersCell"
    
    lazy var viewModel: CurrentWinnersViewModel = {
        return CurrentWinnersViewModel(tableView: tableView, delegate: self, request: Request.currentWinners, dataManager: DataManager(cellIdentifier: cellIdentifier))
    }()
    
    private let segueIdentifier = "toResults"
    private var selectedRace: Race?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataModel()
    }
    
    fileprivate func setupDataModel() {
        viewModel.fetchData()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectedRow = indexPath.row
        self.selectedRace = self.viewModel.data[selectedRow]
        self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard let selectedRace = selectedRace, let vc = segue.destination as? RaceDetailsViewController else { return }
            vc.race = selectedRace
        }
    }
}
