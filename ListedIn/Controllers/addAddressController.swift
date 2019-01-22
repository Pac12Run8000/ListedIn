//
//  addAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class addAddressController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var mainContainer: UIView!
    var viewBackgroundLoading: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicatorView()
        
        view.backgroundColor = UIColor.greenCyan
        mapView.delegate = self
        
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        let searchController = searchControllerForPresentation()
        present(searchController, animated: true, completion: nil)
    }
    
    

}


// MARK:- SearchController functionality
extension addAddressController {
    
    private func searchControllerForPresentation() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        
        searchController.searchBar.barTintColor = UIColor.darkgreen
        searchController.searchBar.tintColor = UIColor.brightGreen_1
        return searchController
    }
}


// MARK:- SearchBarDelegate methods
extension addAddressController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.startActivityIndicator()
        getCoordinatesFromAddress(address: searchBar.text!)
        
    }
}

// MARK:- MKMapViewDelegate methods
extension addAddressController:  MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.stopActivityIndicator()
    }
    
}



// MARK:- ActivityIndicatorView functionality
extension addAddressController {
    
    private func setupActivityIndicatorView() {
        activityIndicator.center = self.view.center
        activityIndicator.style = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        
        mainContainer = UIView(frame: self.view.frame)
        mainContainer.center = self.view.center
        mainContainer.backgroundColor = UIColor.white
        mainContainer.alpha = 0.5
        mainContainer.tag = 431431
        
        
        viewBackgroundLoading = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = self.view.center
        viewBackgroundLoading.backgroundColor = UIColor.darkgreen
        viewBackgroundLoading.alpha = 0.5
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
    }
    
    private func startActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.viewBackgroundLoading.addSubview(self.activityIndicator)
            self.mainContainer.addSubview(self.viewBackgroundLoading)
            
            self.view.addSubview(self.mainContainer)
            self.view.addSubview(self.activityIndicator)
        }
        
    }
    
    private func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        
            for subview in self.view.subviews{
                if subview.tag == 431431 {
                    subview.removeFromSuperview()
                }
            }
            self.activityIndicator.stopAnimating()
    }
}





// MARK: Geocoding functionality
extension addAddressController {
    
    private func getCoordinatesFromAddress(address:String) {
        
        let geoCoder = CLGeocoder()
        var coordinate:CLLocationCoordinate2D!
        
        guard let address = address as? String else {
            print("Please enter a valid address.")
            return
        }
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            guard error == nil else {
                print("There was an error getting placemarks:\(String(describing: error?.localizedDescription))")
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
        }
    }
}






