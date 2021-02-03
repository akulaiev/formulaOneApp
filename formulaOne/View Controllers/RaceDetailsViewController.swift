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
    
    let cellIdentifier = "resultsCell"
    let notificationName = NSNotification.Name("DriverCellSelected")
    
    private var observer: Any!
    private var selectedDriver: Driver?
    private var driverWikiSegue = "driverWiki"
    private var raceWikiSegue = "raceWiki"
    
    var race: Race!
    var viewModel: RaceDetailsViewModel!
    
    deinit {
        NotificationCenter.default.removeObserver(observer!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataModel()
        configureRaceCell()
        listenForSelectedCellNotifications()
    }
    
    func listenForSelectedCellNotifications() {
        observer = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { notification in
            guard let selectedRow = notification.userInfo?["selectedRow"] as? Int else { return }
            self.selectedDriver = self.viewModel.data[0].resultsInfo[selectedRow].driver
            self.performSegue(withIdentifier: self.driverWikiSegue, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == driverWikiSegue || segue.identifier == raceWikiSegue {
            let vc = segue.destination as! WebViewController
            if segue.identifier == driverWikiSegue && selectedDriver != nil {
                vc.urlString = selectedDriver!.url
            } else {
                vc.urlString = race.url
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: raceWikiSegue, sender: self)
    }
    
    fileprivate func setupDataModel() {
        guard let race = race else { return }
        viewModel = RaceDetailsViewModel(tableView: resultsTableView, delegate: self, request: Request.raceResults(year: race.season, round: race.round))
        viewModel.dataManager = DataManager(delegate: viewModel, tableView: resultsTableView, cellIdentifier: cellIdentifier)
        viewModel.fetchData()
        configureRaceCell()
    }
    
    fileprivate func configureRaceCell() {
        raceCell.textLabel?.text = race.season + " - " + race.round
        raceCell.detailTextLabel?.text = race.raceName + " " + race.date
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return tableView.bounds.height * 0.9
        }
        return tableView.bounds.height * 0.1
    }
}