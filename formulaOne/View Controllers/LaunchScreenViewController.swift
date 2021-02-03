//
//  LaunchScreenViewController.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 01.02.2021.
//

import UIKit
import Lottie

class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var animationView: AnimationView!
    
    private let segueIdentifier = "toApp"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.contentMode = .scaleAspectFit
        animationView.play { [self] stopped in
            let seconds = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
    }

}
