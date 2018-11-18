//
//  CityTableViewCell.swift
//  weather_2
//
//  Created by aga on 11/10/18.
//  Copyright © 2018 aga. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet weak var cityNameField: UILabel!
    
    //MARK: - override functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
