//
//  AddAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit


protocol AddAddressControllerDelegate:class {
    func AddAddressController(_ controller:AddAddressController, didFinishAdding item:(address:String?, coordinate:CLLocationCoordinate2D?))
    
    func AddAddressController(_ controller:AddAddressController, didFinishEditing item:RealEstateProperty?)
    
}

class AddAddressController: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var mainContainer: UIView!
    var viewBackgroundLoading: UIView!
    var realEstatePropertyToEdit:RealEstateProperty!
    var editState:Bool!
    
    @IBOutlet weak var labelHeightOutlet: NSLayoutConstraint!
    @IBOutlet weak var addressTextFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    @IBOutlet weak var mapButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var addImageButtonOutlet: UIBarButtonItem!
   
    @IBOutlet weak var notesTextView: UITextView!
    
    
    
    weak var addressDelegate:AddAddressControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicatorView()
        setupErrorLabelAttributes()
        
        notesTextView.layer.cornerRadius = 5
        
        
        addressTextFieldOutlet.delegate = self
        addressTextFieldOutlet.becomeFirstResponder()
        view.backgroundColor = UIColor.greenCyan
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let realEstatePropertyToEdit = realEstatePropertyToEdit {
            addressTextFieldOutlet.text = realEstatePropertyToEdit.address
            editState = true
        } else {
            editState = false
        }
        setEnabledOnMapButton(editState: editState)
    }
    
    @IBAction func mapButtonAction(_ sender: Any) {
        guard let property = realEstatePropertyToEdit else {
            print("There was an error with the RealEstateProperty")
            return
        }
        mapToLocation(latitude: property.latitude, longitude: property.longitude, myAddress: property.address!)
    }
    
    
    
    
    
}
// MARK:- Mapping functionality
extension AddAddressController {
    
    
    private func mapToLocation(latitude:Double, longitude:Double, myAddress:String) {
        let regionDistance:CLLocationDistance = 1000
        let lat:CLLocationDegrees = latitude
        let lng:CLLocationDegrees = longitude
        
        let coordinates:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [MKLaunchOptionsMapCenterKey:NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = myAddress
        mapItem.openInMaps(launchOptions: options)
    }
}

// MARK:- Textfield delegate functionality
extension AddAddressController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textFieldText = textField.text, !textFieldText.isEmpty else {
            
            animateContstraintForErrorMessage(input: 60)
            
            errorLabelOutlet.text = "Please enter an address."
            return false
        }
        startActivityIndicator()
        IsValidAddressConvertedFromCoordinates(address: textFieldText) { (success, coord, error) in
            if (success!) {
                
                self.animateContstraintForErrorMessage(input: 0)
                self.errorLabelOutlet.text = ""
                if let realEstatePropertyToEdit = self.realEstatePropertyToEdit {
                    print("Edit address in CoreData")
                    let updatedRealEstate = self.updateRealEstateProperties(realEstateProperty: realEstatePropertyToEdit, address: textFieldText, coord: coord)
                    self.addressDelegate?.AddAddressController(self, didFinishEditing: updatedRealEstate)
                } else {
                    print("Adding address to CoreData")
                    self.addressDelegate?.AddAddressController(self, didFinishAdding: (address: textFieldText, coordinate: coord))
                }
                self.stopActivityIndicator()
            } else {
                
                self.animateContstraintForErrorMessage(input: 60)
                if let errDesc = error?.localizedDescription {
                    self.errorLabelOutlet.text = "\(String(describing: errDesc))"
                }
                self.stopActivityIndicator()
            }
        }
        return true
    }
}

// MARK:- This is where the error message functionality is located
extension AddAddressController {
    
    private func animateContstraintForErrorMessage(input:CGFloat) {
        self.labelHeightOutlet.constant = input
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
    }
}

// MARK:- ActivityIndicatorView functionality
extension AddAddressController {
    
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
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    private func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        DispatchQueue.main.async {
            for subview in self.view.subviews{
                if subview.tag == 431431 {
                    subview.removeFromSuperview()
                }
            }
            self.activityIndicator.stopAnimating()
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
// MARK:- Setup Button and UIAttributes
extension AddAddressController {
    private func setEnabledOnMapButton(editState:Bool) {
        mapButtonOutlet.isEnabled = editState == true ? true : false
    }

    private func setupErrorLabelAttributes() {
        labelHeightOutlet.constant = 0
        errorLabelOutlet.layer.masksToBounds = true
        errorLabelOutlet.layer.cornerRadius = 7
    }
    
    
    
}

// MARK:- This is the geolocation functionality
extension AddAddressController {
    
    
    private func IsValidAddressConvertedFromCoordinates(address:String, completion:@escaping (_ success:Bool?,_ coords:CLLocationCoordinate2D?,_ myError:Error?) ->()) {
        
        let geoCoder = CLGeocoder()
        var coordinate:CLLocationCoordinate2D!
        
        guard let address = address as? String else {
            print("Please enter a valid address.")
            completion(false, nil, nil)
            return
        }
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard error == nil else {
                print("There was an error getting placemarks:\(String(describing: error?.localizedDescription))")
                completion(false, nil, error)
                return
            }
            
            guard let placemarks = placemarks, placemarks.count > 0 else {
                print("There was an error getting placemarks.")
                completion(false, nil, nil)
                return
            }
            
            guard let location = placemarks.first?.location else {
                print("There was an error getting the location.")
                completion(false, nil, nil)
                return
            }
            coordinate = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            //            self.mapView.setRegion(region, animated: true)
            
            guard let addressString = address as? String, !addressString.isEmpty else {
                print("There was an error with the address input.")
                completion(false, nil, nil)
                return
            }
            
            guard let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude) as? CLLocationCoordinate2D else {
                completion(false, nil, nil)
                return
            }
            
            completion(true,coordinate,nil)
        }
        
    }
    
}


// MARK:- Update functionality for the RealEstateProperty object
extension AddAddressController {
    
    private func updateRealEstateProperties(realEstateProperty:RealEstateProperty,address:String?, coord:CLLocationCoordinate2D?) -> RealEstateProperty? {
        guard let latitude = coord?.latitude, let longitude = coord?.longitude else {
            print("There was the coordinate data.")
            return realEstateProperty
        }
        realEstateProperty.address = address
        realEstateProperty.latitude = latitude
        realEstateProperty.longitude = longitude
        return realEstateProperty
    }
    
}









