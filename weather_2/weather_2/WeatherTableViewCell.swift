//
//  WeatherTableViewCell.swift
//  weather_2
//
//  Created by aga on 11/7/18.
//  Copyright © 2018 aga. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    
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
