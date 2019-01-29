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
    
//    func memeGeneratorViewController(_ controller:MemeGeneratorViewController, didFinishEditing item:MemeObj)
}

class AddAddressController: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var mainContainer: UIView!
    var viewBackgroundLoading: UIView!
    var realEstatePropertyToEdit:RealEstateProperty!
    
    
    @IBOutlet weak var addressTextFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    weak var addressDelegate:AddAddressControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicatorView()
       
        errorLabelOutlet.isHidden = true
        errorLabelOutlet.layer.masksToBounds = true
        errorLabelOutlet.layer.cornerRadius = 7
        
        
        addressTextFieldOutlet.delegate = self
        addressTextFieldOutlet.becomeFirstResponder()
        
        
        view.backgroundColor = UIColor.greenCyan
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let realEstatePropertyToEdit = realEstatePropertyToEdit {
            addressTextFieldOutlet.text = realEstatePropertyToEdit.address
        }
        
        
    }
    

}


// MARK:- Textfield delegate functionality
extension AddAddressController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textFieldText = textField.text, !textFieldText.isEmpty else {
            errorLabelOutlet.isHidden = false
            errorLabelOutlet.text = "Please enter an address."
            return false
        }
        startActivityIndicator()
        IsValidAddressConvertedFromCoordinates(address: textFieldText) { (success, coord, error) in
            if (success!) {
                self.errorLabelOutlet.isHidden = true
                self.errorLabelOutlet.text = ""
                if let realEstatePropertyToEdit = self.realEstatePropertyToEdit {
                    print("Edit address in CoreData")
                    realEstatePropertyToEdit.address = textFieldText
                    realEstatePropertyToEdit.latitude = (coord?.latitude)!
                    realEstatePropertyToEdit.longitude = (coord?.longitude)!
                    self.addressDelegate?.AddAddressController(self, didFinishEditing: realEstatePropertyToEdit)
                } else {
                    print("Adding address to CoreData")
                    self.addressDelegate?.AddAddressController(self, didFinishAdding: (address: textFieldText, coordinate: coord))
                }
                self.stopActivityIndicator()
            } else {
                self.errorLabelOutlet.isHidden = false
                if let errDesc = error?.localizedDescription {
                    self.errorLabelOutlet.text = "\(String(describing: errDesc))"
                }
                self.stopActivityIndicator()
            }
        }
        return true
        
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









