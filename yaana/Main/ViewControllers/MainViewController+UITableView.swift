//
//  MainViewController+UITableView.swift
//  yaana
//
//  Created by SANGAMESH on 08/03/18.
//  Copyright © 2018 Yaana. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TypeOfRows.count.rawValue
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let profileCell = menuTableView.dequeueReusableCell(withIdentifier: "mainMenuProfileCell") as? MainMenuProfileCellTableViewCell else { return UITableViewCell() }
        
        guard let cell = menuTableView.dequeueReusableCell(withIdentifier: "mainMenuOtherCells") as? MainMenuOtherCells else { return UITableViewCell() }
        
        switch indexPath.row {
        case TypeOfRows.profile.rawValue:
            profileCell.awakeFromNib()
            return profileCell
        case TypeOfRows.rates.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.rates.rawValue, imageName: MainMenuImages.rates.rawValue)
            return cell
        case TypeOfRows.promotion.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.promotion.rawValue, imageName: MainMenuImages.promotion.rawValue)
            return cell
        case TypeOfRows.myWallet.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.myWallet.rawValue, imageName: MainMenuImages.myWallet.rawValue)
            return cell
        case TypeOfRows.myRides.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.myRides.rawValue, imageName: MainMenuImages.myRides.rawValue)
            return cell
        case TypeOfRows.termsCo.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.termsCo.rawValue, imageName: MainMenuImages.termsCo.rawValue)
            return cell
        case TypeOfRows.aboutUs.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.aboutUs.rawValue, imageName: MainMenuImages.aboutUs.rawValue)
            return cell
        case TypeOfRows.helpCenter.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.helpCenter.rawValue, imageName: MainMenuImages.helpCenter.rawValue)
            return cell
        case TypeOfRows.signOut.rawValue:
            cell.configureCells(menuLabelValue: MainMenu.signOut.rawValue, imageName: MainMenuImages.signOut.rawValue)
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
}
