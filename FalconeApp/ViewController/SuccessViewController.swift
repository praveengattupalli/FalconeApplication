//
//  SuccessViewController.swift
//  FalconeApp
//
//  Created by praveen on 3/3/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation
import UIKit

class SuccessViewController: UIViewController {
    
    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var planetFoundLabel: UILabel!
    @IBOutlet weak var startAgainButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!
    var response: FindFalconeResponse?
    var timeTaken: String?
    var success: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if success {
            planetFoundLabel.text = response?.planetName
        } else {
            successLabel.text = "Failed to find Falcone."
        }
        timeTakenLabel.text = timeTaken
        startAgainButton.addTarget(self, action: #selector(startAgainClicked),
                                   for: .touchUpInside)
    }
    
    @objc func startAgainClicked() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}
