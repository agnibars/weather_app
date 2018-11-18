//
//  DetailViewController.swift
//  weather_2
//
//  Created by aga on 11/6/18.
//  Copyright © 2018 aga. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var cityNameField: UINavigationItem!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var maxTempField: UITextField!
    @IBOutlet weak var minTempField: UITextField!
    @IBOutlet weak var windSpeedField: UITextField!
    @IBOutlet weak var windBearingField: UITextField!
    @IBOutlet weak var percipField: UITextField!
    @IBOutlet weak var pressureField: UITextField!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: - Properties
    var whichDay: Int = 0
    var weatherDataTable: [MasterViewController.OneDayWeatherData] = []

    //MARK: - view functions
    func configureView() {
        // Update the user interface for the detail item.
        if let cityWeather = detailItem {
            cityNameField.title = cityWeather.cityName
            weatherDataTable = cityWeather.forecast ?? []
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        updateView()
    }
    
    func updateView(){
        let date = Date(timeIntervalSince1970: self.weatherDataTable[whichDay].time ?? 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateField.text = dateFormatter.string(from: date)
        self.maxTempField.text = String(format: "%.1f", self.weatherDataTable[whichDay].tempMax ?? "0.0")
        self.minTempField.text = String(format: "%.1f", self.weatherDataTable[whichDay].tempMin ?? "0.0")
        self.windSpeedField.text = String(format: "%.1f", self.weatherDataTable[whichDay].windSpeed ?? "0.0")
        self.windBearingField.text = String(format: "%d", self.weatherDataTable[whichDay].windBearing ?? "0.0")
        self.percipField.text = String(format: "%.4f", self.weatherDataTable[whichDay].precipIntensity ?? "0.0")
        self.pressureField.text = String(format: "%.0f", self.weatherDataTable[whichDay].pressure ?? "0.0")
        let nameOfIconInResponse = weatherDataTable[whichDay].icon
        let imageName = MasterViewController().iconFromName(iconName: nameOfIconInResponse ?? "defaultPicture")
        self.iconImage.image = UIImage(named: imageName)
    }

    var detailItem: MasterViewController.cityWeather? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func changeToPrevious(_ sender: Any) {
        if (whichDay > 0){
            whichDay -= 1
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    

    @IBAction func changeToNext(_ sender: Any) {
        if (whichDay < self.weatherDataTable.count - 1){
            whichDay += 1
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = (segue.destination as! UINavigationController).topViewController as? CityMapViewController
        controller?.cityName = cityNameField.title ?? "Rome"
    }

}

