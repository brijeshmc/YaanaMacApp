//
//  MainViewController.swift
//  yaana
//
//  Created by SANGAMESH on 08/03/18.
//  Copyright © 2018 Yaana. All rights reserved.
//

import UIKit
import MapKit

enum MainMenu: String {
    
    case profile = "Name"
    case rates = "Rates"
    case promotion = "Promotion"
    case myWallet = "My Wallet"
    case myRides = "My Rides"
    case termsCo = "Terms and Conditions"
    case aboutUs = "About Us"
    case helpCenter = "Help Center"
    case signOut = "Sign Out"

}

enum TypeOfRows: Int {
    
    case profile = 0
    case rates
    case promotion
    case myWallet
    case myRides
    case termsCo
    case aboutUs
    case helpCenter
    case signOut
    
    case count
}

enum MainMenuImages: String {
    case profile = "Name"
    case rates = "Rates"
    case promotion = "Promotion"
    case myWallet = "My Wallet"
    case myRides = "My Rides"
    case termsCo = "Terms and Conditions"
    case aboutUs = "About Us"
    case helpCenter = "Help Center"
    case signOut = "Sign Out"
}

class MainViewController: UIViewController {
  
    //All outlets
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var hamburgerButton: UIBarButtonItem!
    @IBOutlet weak var mapViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapViewLeadingConstraint: NSLayoutConstraint!
    
    //All variables
    var hamburgerMenuIsVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func hamburgerPressed(_ sender: Any) {
        if !hamburgerMenuIsVisible {
            mapViewLeadingConstraint.constant = 150
            mapViewTrailingConstraint.constant = -150
            hamburgerMenuIsVisible = true
        } else {
            mapViewLeadingConstraint.constant = 0
            mapViewTrailingConstraint.constant = 0
            hamburgerMenuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete")
        }
    }
    

}
