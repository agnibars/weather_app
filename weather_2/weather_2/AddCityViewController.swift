//
//  AddCityViewController.swift
//  weather_2
//
//  Created by aga on 11/10/18.
//  Copyright © 2018 aga. All rights reserved.
//

import UIKit
import MapKit

class AddCityViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    
    //MARK: - Outlets
    @IBOutlet weak var enterCityField: UITextField!
    @IBOutlet weak var citiesTable: UITableView!
    @IBOutlet weak var currentLocButton: UIButton!
    @IBOutlet weak var currentLocField: UILabel!
    
    //MARK: - Properties
    var citiesToDisplay = [City]()
    var pickedCity: City?
    var locationManager = CLLocationManager()
    var currentCoords = ""
    var currentCity = ""
    
    //MARK: - Structs
    struct City {
        var cityName:String?
        var coordinates:String?
    }
    
    //MARK: - view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        enterCityField.delegate = self
        citiesTable.dataSource = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: - managing location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lat = String(format: "%f", manager.location?.coordinate.latitude ?? "50.064528")
        let long = String(format: "%f", manager.location?.coordinate.longitude ?? "19.923556")
        currentCoords = lat + "," + long
        let geocoder = CLGeocoder()
        if let lastLocation = manager.location {
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                let firstPlacemark = placemarks?.first
                self.currentCity = firstPlacemark?.locality ?? ""
                let currCountry = firstPlacemark?.country ?? ""
                let currLocText = "You are currently in: " + self.currentCity + ", " + currCountry
                self.currentLocField.text = currLocText
            })
        }
    }
    
    //MARK: - getting weather data & displaying it
    private func searchForCitiesNamesAndCoords(query: String, completionHandler: @escaping (([City]) -> Void)){
        var tmpCitiesTable: [City] = []
        var suffix = ""
        if containsAnyLetters(input: query){
            suffix = "query="
        } else {
            suffix = "lattlong="
        }
        let noSpaceQuery = query.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let urlString = "https://www.metaweather.com/api/location/search/?" + suffix + noSpaceQuery
        guard let url = URL(string: urlString) else {
            print("problem z URL")
            completionHandler(tmpCitiesTable)
            return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                if let citiesTable = jsonResponse as? NSArray{
                    var citiesTableElement: City! = City()
                    for cityData in (citiesTable as NSArray) {
                        let city = cityData as? [String: Any]
                        citiesTableElement.cityName = city!["title"] as? String
                        citiesTableElement.coordinates = city!["latt_long"] as? String
                        tmpCitiesTable.append(citiesTableElement)
                    }
                }
                completionHandler(tmpCitiesTable.reversed())
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    func containsAnyLetters(input: String) -> Bool {
        for chr in input {
            if ((chr >= "a" && chr <= "z") || (chr >= "A" && chr <= "Z") ) {
                return true
            }
        }
        return false
    }
    
    func insertCities(cTable: [City]){
        for cityData in cTable {
            let newCity = City(cityName: cityData.cityName, coordinates: cityData.coordinates)
            citiesToDisplay.insert(newCity, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            citiesTable.insertRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    
    //MARK: - Actions
    @IBAction func searchForCities(_ sender: Any) {
        let group = DispatchGroup()
        group.enter()
        var tmpCities:[City] = []
        searchForCitiesNamesAndCoords(query: enterCityField.text ?? "Rome", completionHandler: { cT in
            tmpCities = cT
            group.leave()
        })
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.insertCities(cTable: tmpCities)
            }
        }
        
    }
    
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        print(currentCity)
        print(currentCoords)
        let group = DispatchGroup()
        let group2 = DispatchGroup()
        group.enter()
        var tmpCities:[City] = []
        searchForCitiesNamesAndCoords(query: currentCity, completionHandler: { cT in
            tmpCities = cT
            group.leave()
        })
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.insertCities(cTable: tmpCities)
                if tmpCities.count == 0 {
                    group2.enter()
                    self.searchForCitiesNamesAndCoords(query: self.currentCoords, completionHandler: { cT2 in
                        tmpCities = cT2
                        print(tmpCities)
                        group2.leave()
                    })
                    group2.notify(queue: .main) {
                        DispatchQueue.main.async {
                            self.insertCities(cTable: tmpCities)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let cell = sender as? CityTableViewCell {
            pickedCity = citiesToDisplay.first{$0.cityName == cell.cityNameField.text}
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
   
}


//MARK: - Table View Data Source
extension AddCityViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CityCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CityTableViewCell else {
            fatalError("The dequeued cell is not an instance of WeatherTableViewCell.")
        }
        let city = citiesToDisplay[indexPath.row]
        cell.cityNameField.text = city.cityName
        return cell
    }
}
