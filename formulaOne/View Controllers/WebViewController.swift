//
//  WebViewController.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 31.01.2021.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        guard let url = URL(string: urlString) else {
            HelperMethods.showFailureAlert(title: "Warning", message: "Invalid URL", controller: self)
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        HelperMethods.showFailureAlert(title: "Warning", message: error.localizedDescription, controller: self)
    }
}
