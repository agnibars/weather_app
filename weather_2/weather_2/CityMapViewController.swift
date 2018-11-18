//
//  CityMapViewController.swift
//  weather_2
//
//  Created by aga on 11/17/18.
//  Copyright © 2018 aga. All rights reserved.
//

import UIKit
import MapKit

class CityMapViewController: UIViewController {

    var cityName:String = "empty"
    
    //MARK: - Outletss
    @IBOutlet weak var cityMapView: MKMapView!
    
    //MARK: - view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myGeocoder = CLGeocoder()
        let group = DispatchGroup()
        var cityCoords = CLLocationCoordinate2D(latitude: 50.064528, longitude: 19.923556)
        group.enter()
        myGeocoder.geocodeAddressString(cityName) { (placemarks, error) in
            let firstPlacemark = placemarks?.first
            cityCoords = firstPlacemark?.location?.coordinate ?? CLLocationCoordinate2D(latitude: 50.064528, longitude: 19.923556)
            group.leave()
        }
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.cityMapView.setCenter(cityCoords, animated: true)
                let region = MKCoordinateRegion(center: cityCoords, latitudinalMeters: 5000, longitudinalMeters: 5000)
                self.cityMapView.setRegion(region, animated: true)
                let annotation = MKPointAnnotation()
                annotation.title = self.cityName
                annotation.coordinate = cityCoords
                self.cityMapView.addAnnotation(annotation)
            }
        }
        
    }

}
