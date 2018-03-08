//
//  MainMenuOtherCells.swift
//  yaana
//
//  Created by SANGAMESH on 09/03/18.
//  Copyright © 2018 Yaana. All rights reserved.
//

import UIKit

class MainMenuOtherCells: UITableViewCell {

    @IBOutlet weak var menuImageIcon: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCells(menuLabelValue: MainMenu.RawValue, imageName: String) {
       menuImageIcon.image = UIImage(named: imageName)
       menuLabel.text = menuLabelValue
    }
    
}
