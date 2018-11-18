//
//  MasterViewController.swift
//  weather_2
//
//  Created by aga on 11/6/18.
//  Copyright © 2018 aga. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    
    //MARK: - Properties
    var detailViewController: DetailViewController? = nil
    var objects = [cityWeather]()
    
    //MARK: - Structs
    struct OneDayWeatherData{
        var time:TimeInterval?
        var icon:String?
        var tempMax:Double?
        var tempMin:Double?
        var windSpeed:Double?
        var windBearing:Int?
        var precipIntensity:Double?
        var pressure:Double?
    }

    struct cityWeather{
        var cityName:String?
        var forecast:[OneDayWeatherData]?
    }

    //MARK: - view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load 3 cities
        let cityName1 = "Boston"
        let cityName2 = "London"
        let cityName3 = "Baltimore"
        let url1 = "https://api.darksky.net/forecast/2e1044a3a8f9cd19c387a7634268e4f2/42.3601,-71.0589?exclude=currently,minutely,hourly,alerts,flags"
        let url2 = "https://api.darksky.net/forecast/2e1044a3a8f9cd19c387a7634268e4f2/51.5098,-0.1180?exclude=currently,minutely,hourly,alerts,flags"
        let url3 = "https://api.darksky.net/forecast/2e1044a3a8f9cd19c387a7634268e4f2/39.2992,-76.6093?exclude=currently,minutely,hourly,alerts,flags"

        self.addNewCity(cityName: cityName1, url: url1)
        self.addNewCity(cityName: cityName2, url: url2)
        self.addNewCity(cityName: cityName3, url: url3)
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    //MARK: - getting weather data & displaying it
    func addNewCity(cityName: String, url: String){
        
        let group = DispatchGroup()
        group.enter()
        var tmpForecast:[OneDayWeatherData] = []
        getWeatherDataForCity(url: url, completionHandler: { wDT in
            tmpForecast = wDT
            group.leave()
        })
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.insertNewCityWeather(cityName: cityName, weatherData: tmpForecast)
            }
        }
        
    }
    
    private func getWeatherDataForCity(url: String, completionHandler: @escaping (([OneDayWeatherData]) -> Void)){
        guard let url = URL(string: url) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                var tmpWeatherDataTable: [OneDayWeatherData] = []
                if let dictionary = jsonResponse as? [String: Any] {
                    if let nestedDaily = dictionary["daily"] as? [String: Any]{
                        if let nestedData = nestedDaily["data"] as? NSArray{
                            var weatherDataElement: OneDayWeatherData! = OneDayWeatherData()
                            for oneDayData in (nestedData as NSArray) {
                                let oneDayDict = oneDayData as? [String: Any]
                                weatherDataElement.time = oneDayDict!["time"] as? TimeInterval
                                weatherDataElement.icon = oneDayDict!["icon"] as? String
                                weatherDataElement.tempMax = oneDayDict!["temperatureMax"] as? Double
                                weatherDataElement.tempMin = oneDayDict!["temperatureMin"] as? Double
                                weatherDataElement.windSpeed = oneDayDict!["windSpeed"] as? Double
                                weatherDataElement.windBearing = oneDayDict!["windBearing"] as? Int
                                weatherDataElement.precipIntensity = oneDayDict!["precipIntensity"] as? Double
                                weatherDataElement.pressure = oneDayDict!["pressure"] as? Double
                                tmpWeatherDataTable.append(weatherDataElement)
                            }
                        }
                    }
                }
                completionHandler(tmpWeatherDataTable)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    
    func insertNewCityWeather(cityName: String, weatherData:[OneDayWeatherData]){
        let newCityWeather = cityWeather(cityName: cityName, forecast: weatherData)
        objects.insert(newCityWeather, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as cityWeather
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WeatherCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WeatherTableViewCell else {
            fatalError("The dequeued cell is not an instance of WeatherTableViewCell.")
        }

        let object = objects[indexPath.row]
        cell.cityNameLabel.text = object.cityName
        cell.temperatureLabel.text = String(format: "%.1f", object.forecast?[0].tempMax ?? "0.0")
        let nameOfIconInResponse = object.forecast?[0].icon
        let imageName = self.iconFromName(iconName: nameOfIconInResponse ?? "defaultPicture")
        cell.iconImage.image = UIImage(named: imageName)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    //MARK: - icon name translation
    func iconFromName(iconName: String) -> String {
        switch iconName {
        case "clear-day":
            return "sun"
        case "clear-night":
            return "moon"
        case "rain":
            return "rain"
        case "snow":
            return "snow"
        case "sleet":
            return "sleet"
        case "wind":
            return "wind"
        case "fog":
            return "fog"
        case "cloudy":
            return "cloud"
        case "partly-cloudy-day":
            return "cloudDay"
        case "partly-cloudy-night":
            return "cloudNight"
        default:
            return "defaultPicture"
        }
    }

    //MARK: - Actions
    @IBAction func unwindToMasterView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddCityViewController, let city = sourceViewController.pickedCity {
         let cityUrl = "https://api.darksky.net/forecast/2e1044a3a8f9cd19c387a7634268e4f2/" + (city.coordinates ?? "41.903111,12.495760") + "?exclude=currently,minutely,hourly,alerts,flags"
         self.addNewCity(cityName: city.cityName ?? "Rome", url: cityUrl)
         }
    }

}

