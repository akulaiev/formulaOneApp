//
//  RaceDetailsViewController.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 30.01.2021.
//

import UIKit

class RaceDetailsViewController: UITableViewController, ViewModelDelegate {
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var raceCell: UITableViewCell!
    
    private var selectedDriver: Driver?
    private var driverWikiSegue = "driverWiki"
    private var raceWikiSegue = "raceWiki"
    
    lazy var viewModel: RaceDetailsViewModel? = {
        guard let race = race else { return nil }
        return RaceDetailsViewModel(tableView: resultsTableView, delegate: self, request: Request.raceResults(year: race.season, round: race.round), dataManager: DataManager(cellIdentifier: cellIdentifier))
    }()
    
    let cellIdentifier = "resultsCell"
    var race: Race?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataModel()
        configureRaceCell()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let selectedRow = indexPath.row
        selectedDriver = viewModel.data[0].resultsInfo[selectedRow].driver
        performSegue(withIdentifier: self.driverWikiSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WebViewController, segue.identifier == driverWikiSegue || segue.identifier == raceWikiSegue {
            if let selectedDriver = selectedDriver, segue.identifier == driverWikiSegue {
                vc.urlString = selectedDriver.url
            } else if let race = race {
                vc.urlString = race.url
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: raceWikiSegue, sender: self)
    }
    
    fileprivate func setupDataModel() {
        guard let viewModel = viewModel else { return }
        viewModel.fetchData()
        configureRaceCell()
    }
    
    fileprivate func configureRaceCell() {
        guard let race = race else { return }
        raceCell.textLabel?.text = race.season + " - " + race.round
        raceCell.detailTextLabel?.text = race.raceName + " " + race.date
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return tableView.bounds.height * 0.75
        }
        return tableView.bounds.height * 0.1
    }
}
