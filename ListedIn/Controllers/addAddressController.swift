//
//  addAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class addAddressController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.greenCyan
        mapView.delegate = self
        
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        
        searchController.searchBar.barTintColor = UIColor.darkgreen
        searchController.searchBar.tintColor = UIColor.brightGreen_1
        
        present(searchController, animated: true, completion: nil)
        
    }
    
    

}

extension addAddressController: MKMapViewDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getCoordinatesFromAddress(address: searchBar.text!)
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        UIApplication.shared.beginIgnoringInteractionEvents()
//
//        let activityIndicator = UIActivityIndicatorView()
//        activityIndicator.style = .whiteLarge
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.startAnimating()
//        self.view.addSubview(activityIndicator)
//
//        searchBar.resignFirstResponder()
//        dismiss(animated: true, completion: nil)
//
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = searchBar.text
//
//        let activeSearch = MKLocalSearch(request: searchRequest)
//        activeSearch.start { (response, error) in
//
//            activityIndicator.stopAnimating()
//            UIApplication.shared.endIgnoringInteractionEvents()
//
//            guard error == nil else {
//                print("There was an error:\(String(describing: error?.localizedDescription))")
//                return
//            }
//            guard let response = response else {
//                print("There was no response.")
//                return
//            }
//
//            let annotations = self.mapView.annotations
//            self.mapView.removeAnnotations(annotations)
//
//            guard let latitude = response.boundingRegion.center.latitude as? CLLocationDegrees, let longitude = response.boundingRegion.center.longitude as? CLLocationDegrees else {
//                print("There was an error getting the latitude and longitude.")
//                return
//            }
//
//
//
//            let annotation = MKPointAnnotation()
//            annotation.title = searchBar.text
//            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
//            self.mapView.addAnnotation(annotation)
//
//
//            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            let region = MKCoordinateRegion(center: coordinate, span: span)
//            self.mapView.setRegion(region, animated: true)
//        }
//    }
    
}


//var coordinate:CLLocationCoordinate2D?
//
//guard let locationString = locationString as? String else {
//    completionHandler(nil, "No location was entered.")
//    return
//}
//
//geocoder.geocodeAddressString(locationString) { (placemarks, error) in
//    guard error == nil else {
//        completionHandler(nil, "error:\(String(describing: error?.localizedDescription))")
//        return
//    }
//    var location:CLLocation?
//
//    if let placemarks = placemarks, placemarks.count > 0 {
//        location = placemarks.first?.location
//    }
//
//    if let location = location {
//        coordinate = location.coordinate
//        completionHandler(coordinate, nil)
//    }
//}




// MARK: Geocoding functionality
extension addAddressController {
    
    private func getCoordinatesFromAddress(address:String) {
        var geoCoder = CLGeocoder()
        var coordinate:CLLocationCoordinate2D!
        
        guard let address = address as? String else {
            print("Please enter a valid address.")
            return
        }
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            guard error == nil else {
                print("There was an error getting placemarks:\(error?.localizedDescription)")
                return
            }
            
            guard let placemarks = placemarks, placemarks.count > 0 else {
                print("There was an error getting placemarks.")
                return
            }
            
            guard let location = placemarks.first?.location else {
                print("There was an error getting the location.")
                return
            }
            coordinate = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            guard let addressString = address as? String, !addressString.isEmpty else {
                print("There was an error with the address input.")
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = addressString
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.mapView.addAnnotation(annotation)
            
//            var location:CLLocation?
//            if let placemarks = placemarks, placemarks.count > 0 {
//                location = placemarks.first?.location
//            }
//            if let location = location {
//                coordinate = location.coordinate
//                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//                let region = MKCoordinateRegion(center: coordinate, span: span)
//                self.mapView.setRegion(region, animated: true)
//            }
        }
        
    }
}






