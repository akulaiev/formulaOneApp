//
//  PastRacesViewController.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 01.02.2021.
//

import UIKit

class PastRacesViewController: UIViewController, ViewModelDelegate {
    @IBOutlet weak var yearPickerButton: UIButton!
    @IBOutlet weak var placePickerButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var placePickerView: UIPickerView!
    
    private var observer: Any!
    private var selectedDriver: Driver?
    private let segueIdentifier = "pastDriverWiki"
    
    var viewModel: PastRacesViewModel!
    let cellIdentifier = "filteredRaceInfo"
    let notificationName = NSNotification.Name("PastRacesCellPicked")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataModel()
    }
    
    fileprivate func setupDataModel() {
        viewModel = PastRacesViewModel(tableView: tableView, delegate: self, request: Request.pastRaces(year: "", place: ""), pickerViews: [yearPickerView, placePickerView], pickerButtons: [yearPickerButton, placePickerButton])
        viewModel.dataManager = DataManager(delegate: viewModel, tableView: tableView, cellIdentifier: cellIdentifier)
        viewModel.configurePickersDelegates()
        listenForSelectedCellNotifications()
    }
    
    func listenForSelectedCellNotifications() {
        observer = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { notification in
            guard let selectedRow = notification.userInfo?["selectedRow"] as? Int else { return }
            self.selectedDriver = self.viewModel.data[selectedRow].resultsInfo[0].driver
            self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier && selectedDriver != nil{
            let vc = segue.destination as! WebViewController
            vc.urlString = selectedDriver!.url
        }
    }
    
    @IBAction func pickerButtonTapped(_ sender: UIButton) {
        if sender.tag == 30 {
            yearPickerView.manageState(showPickerView: yearPickerView.isHidden, tableView: tableView)
        } else if sender.tag == 40 {
            placePickerView.manageState(showPickerView: placePickerView.isHidden, tableView: tableView)
        }
    }
}

