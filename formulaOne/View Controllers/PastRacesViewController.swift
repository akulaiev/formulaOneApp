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
    
    private var selectedRace: Race?
    private let segueIdentifier = "pastDriverWiki"
    
    var viewModel: PastRacesViewModel!
    let cellIdentifier = "filteredRaceInfo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataModel()
    }
    
    fileprivate func setupDataModel() {
        viewModel = PastRacesViewModel(tableView: tableView, cellIdentifier: cellIdentifier, delegate: self, request: Request.pastRaces(year: "", place: ""), pickerViews: [yearPickerView, placePickerView], pickerButtons: [yearPickerButton, placePickerButton])
        viewModel.configurePickersDelegates()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectedRow = indexPath.row
        self.selectedRace = self.viewModel.data[selectedRow]
        self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedRace = selectedRace, segue.identifier == segueIdentifier {
            let vc = segue.destination as! WebViewController
            vc.urlString = selectedRace.url
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

