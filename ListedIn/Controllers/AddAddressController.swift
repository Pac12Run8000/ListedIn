//
//  AddAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import CoreData


protocol AddAddressControllerDelegate:class {
    func AddAddressController(_ controller:AddAddressController, didFinishAdding item:(address:String?, coordinate:CLLocationCoordinate2D?))
    
    func AddAddressController(_ controller:AddAddressController, didFinishEditing item:RealEstateProperty?)
}

class AddAddressController: UIViewController {
    

    
    var realEstateImagesArray:[RealEstateImages] = [RealEstateImages]()
    var dataController:DataController!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var mainContainer: UIView!
    var viewBackgroundLoading: UIView!
    var realEstatePropertyToEdit:RealEstateProperty!
    var editState:Bool!
    var actionSheet:UIAlertController!
    var isCollectionViewInEditingMode:Bool = true
    
    

    
    @IBOutlet weak var labelHeightOutlet: NSLayoutConstraint!
    @IBOutlet weak var addressTextFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    @IBOutlet weak var mapButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var addImageButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var notesButtonOutlet: UIBarButtonItem!
   
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var editImageOutlet: UIBarButtonItem!
    
    
    weak var addressDelegate:AddAddressControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRealEstateImages(controller: dataController) { (success, images, err) in
            if (success!) {

                if let images = images {
                    self.realEstateImagesArray = images
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } else {
                let myError = err == nil ? "No error description available" : err?.localizedDescription
                print("There was an error: \(String(describing: myError))")
            }
        }

        
        setupActivityIndicatorView()
        setupErrorLabelAttributes()
        setupCollectionViewDelegateAndDatasource()
        collectionView.collectionViewLayout = setupFlowLayout()
        setnotesTextViewProperties()
        
        addressTextFieldOutlet.delegate = self
        makeAddressTextFieldFirstResponder()
        setDismissKeyboard()
        
        
        setupBgColor()
        setCollectionViewAppearance()
        
    }
    
    
    private func returnImagesArray(r_Images:[RealEstateImages]) -> [RealEstateImages]? {
        var imagesArray = [RealEstateImages]()
        for image in r_Images {
            imagesArray.append(image)
        }
        return imagesArray
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        

        
        editState = setEditState(realEstateProperty: realEstatePropertyToEdit)
        
        notesTextView.text = setRealEstatePropertyNotesText(realEstateProperty: realEstatePropertyToEdit)
        setVisibilityForNotesTextView(editState: editState)
        setVisibilityForCollectionView(editState: editState)
        setAddressTextField(realEstatePropertyToEdit: realEstatePropertyToEdit)
        setEnabledMapButton(editState: editState)
        setupEnableImageButton(editState: editState)
        setupEnableNoteButton(editState: editState)
        setupDeleteNoteButtonOutlet(myEditState: editState)
        
        
    }
    
    @IBAction func editImageAction(_ sender: Any) {
        isCollectionViewInEditingMode = !isCollectionViewInEditingMode
        collectionView.reloadData()
        
        isDeleteNotesButtonHidden(localEditState: editState, deleteBtn: deleteButtonOutlet)
        // MARK: Delete (trash can icon) icon is set here
        editImageOutlet.tintColor = isCollectionViewInEditingMode ? UIColor.brightGreen_1 : UIColor.red
        
        

    }
    
    
    @IBAction func imagesAction(_ sender: Any) {
        self.addPhotoFromCameraOrLibrary()
    }
    
    
    
    @IBAction func mapButtonAction(_ sender: Any) {
        guard let property = realEstatePropertyToEdit else {
            print("There was an error with the RealEstateProperty")
            return
        }
        mapToLocation(latitude: property.latitude, longitude: property.longitude, myAddress: property.address!)
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        if let realEstatePropertyToEdit = realEstatePropertyToEdit {
            realEstatePropertyToEdit.note = ""
            
            saveCoreData(controller: dataController) { (success, error) in
                if (success!) {
                    self.animateNotesFunctionalityFading(textView: self.notesTextView, button: self.deleteButtonOutlet, completionHandler: {
                        self.notesTextView.text = ""
                    })
                } else {
                    print("There was an error setting note to empty string.\(error!.localizedDescription)")
                }
            }
            
        }
    }
}

// MARK:- Animation functionality
extension AddAddressController {
    
    private func animateNotesFunctionalityFading(textView:UITextView, button:UIButton, completionHandler:@escaping() -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                
                textView.alpha = 0.0
                button.alpha = 0.0
                
            }, completion: nil)
        })
    }
    
}

// MARK:- CoreData Functionality
extension AddAddressController {
    
    private func saveCoreData(controller:DataController, completionHandler handler:@escaping(_ success:Bool?, _ error:Error?) ->()) {
        do {
            try controller.viewContext.save()
            handler(true, nil)
        } catch {
            handler(false, error)
        }
    }
    

    
    
    private func getRealEstateImages(controller:DataController? = nil, completionHandler:@escaping(_ success:Bool?,_ images:[RealEstateImages]?, _ error:Error?) -> ()) {

        guard controller != nil else {
            print("dataController is nil")
            completionHandler(false, nil, nil)
            return
        }


            var results:[RealEstateImages]!

            let fetchRequest:NSFetchRequest<RealEstateImages> = RealEstateImages.fetchRequest()
            let predicate = NSPredicate(format: "realEstateProperty = %@", realEstatePropertyToEdit)
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                results = try controller?.viewContext.fetch(fetchRequest)
                completionHandler(true, results, nil)
            } catch {
                print("There was an error with the images")
                completionHandler(false, nil, nil)
            }
    }
    
    
    
    
}




// MARK:- Delete button, noteTextField Layout isHidden functionality
extension AddAddressController {
    
    
    private func setupDeleteNoteButtonOutlet(myEditState: Bool) {
        
        deleteButtonOutlet.alpha = 1.0
        deleteButtonOutlet.backgroundColor = UIColor.red
        deleteButtonOutlet.setTitleColor(UIColor.brightGreen_1, for: .normal)
        deleteButtonOutlet.layer.cornerRadius = 4
        deleteButtonOutlet.layer.borderWidth = 2
        deleteButtonOutlet.layer.borderColor = UIColor.brightGreen_1.cgColor
        deleteButtonOutlet.setTitle("delete note", for: .normal)
        
        isDeleteNotesButtonHidden(localEditState: editState, deleteBtn: deleteButtonOutlet)
        
    }
    
    private func setRealEstatePropertyNotesText(realEstateProperty:RealEstateProperty?) -> String {
        if let note = realEstateProperty?.note as? String {
            return note
        }
        return ""
    }
    
    private func setVisibilityForCollectionView(editState:Bool) {
        collectionView.isHidden = editState == true ? false : true
    }
    
    private func setVisibilityForNotesTextView(editState:Bool) {
        notesTextView.alpha = 1.0
        if (editState == true) {
            if ((realEstatePropertyToEdit.note?.isEmpty)! || realEstatePropertyToEdit.note == "") {
                notesTextView.isHidden = true
            } else {
                notesTextView.isHidden = false
            }
        } else {
            notesTextView.isHidden = true
        }
    }
    
    private func setEditState(realEstateProperty: RealEstateProperty?) -> Bool {
        return realEstateProperty == .none ? false : true
    }
    
    private func setAddressTextField(realEstatePropertyToEdit:RealEstateProperty?) {
        if let realEstatePropertyToEdit = realEstatePropertyToEdit as? RealEstateProperty {
            addressTextFieldOutlet.text = realEstatePropertyToEdit.address
        }
    }
    
    private func setCollectionViewAppearance() {
        collectionView.layer.cornerRadius = 4
        collectionView.backgroundColor = UIColor.darkgreen
    }
    
    private func setupBgColor() {
        view.backgroundColor = UIColor.greenCyan
    }
    

    
    private func setnotesTextViewProperties() {
        notesTextView.backgroundColor = UIColor.greenCyan
        notesTextView.textColor = UIColor.white
    }
    
}


// MARK:- Make elements on cotroller visible or not, enabled or not
extension AddAddressController {
    
    private func setupEnableNoteButton(editState:Bool) {
        notesButtonOutlet.isEnabled = editState == true ? true : false
    }
    
    private func setupEnableImageButton(editState:Bool) {
        addImageButtonOutlet.isEnabled = editState == true ? true : false
    }
    
    private func setEnabledMapButton(editState:Bool) {
        mapButtonOutlet.isEnabled = editState == true ? true : false
    }
    
    private func setupErrorLabelAttributes() {
        labelHeightOutlet.constant = 0
        errorLabelOutlet.layer.masksToBounds = true
        errorLabelOutlet.layer.cornerRadius = 7
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

// MARK:- Keyboard dismiss and present functionality
extension AddAddressController {
    
    private func setDismissKeyboard() {
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddAddressController.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func makeAddressTextFieldFirstResponder() {
        addressTextFieldOutlet.becomeFirstResponder()
    }
    
    @objc private func dismissKeyboard(tap:UITapGestureRecognizer) {
//        addressTextFieldOutlet.resignFirstResponder()
        view.endEditing(true)
    }
    
}

// MARK:- Textfield delegate functionality
extension AddAddressController: UITextFieldDelegate {
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textFieldText = textField.text, !textFieldText.isEmpty else {
            
            animateContstraintForErrorMessage(input: 60, constraintToAnimate: labelHeightOutlet)
            
            errorLabelOutlet.text = "Please enter an address."
            return false
        }
        startActivityIndicator()
        IsValidAddressConvertedFromCoordinates(address: textFieldText) { (success, coord, error) in
            if (success!) {
                
                self.animateContstraintForErrorMessage(input: 0, constraintToAnimate: self.labelHeightOutlet)
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
                
                self.animateContstraintForErrorMessage(input: 60, constraintToAnimate: self.labelHeightOutlet)
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
    
    private func animateContstraintForErrorMessage(input:CGFloat, constraintToAnimate: NSLayoutConstraint ) {
        constraintToAnimate.constant = input
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


// MARK:- CollectionViewDataSource and CollectionViewDelegate functionality
extension AddAddressController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    private func setupCollectionViewDelegateAndDatasource() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let realEstateImagesArray = realEstateImagesArray as? [RealEstateImages] {
            return realEstateImagesArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCollectionViewCell
        
        cell?.realEstateImage = realEstateImagesArray[indexPath.row]
        cell?.deleteButtonBackgroundBackgroundView.isHidden = isCollectionViewInEditingMode
        cell?.customCellDelegate = self
        
        return cell!
    }
    
    
    
}

// MARK:- Prepare for segue functionality
extension AddAddressController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "notesSegue") {
            let controller = segue.destination as! NotesViewController
            controller.dataController = dataController
            if let realEstateProperty = realEstatePropertyToEdit {
                controller.realEstateProperty = realEstateProperty
            }
        } else if (segue.identifier == "carouselSegue") {
            let controller = segue.destination as! CarouselViewController
            controller.imagesArray = realEstateImagesArray
        }
    }
    
    
}

// MARK:- FlowLayout functionality
extension AddAddressController {
    
    private func setupFlowLayout() -> UICollectionViewFlowLayout {
        
        let layout = UICollectionViewFlowLayout()
        let space:CGFloat = 3.0
//        let dimension = ((view.frame.size.width - 10) - (3 * space)) / 4.0
        let dimension = ((view.frame.size.width - 10) - (2 * space)) / 3.0
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        
        return layout
    }
    
}


// MARK:- Camera and PhotoLibrary ActionSheet functionality
extension AddAddressController {
    
    private func addPhotoFromCameraOrLibrary() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        actionSheet = UIAlertController(title: "Choose Media", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("The camera isn't available")
                self.alertNotification(message: "The camera isn't available on this device.")
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
}
// MARK:- AlertController functionality
extension AddAddressController {
    
    private func alertNotification(message:String) {
        let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}


// MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate functionality
extension AddAddressController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            picker.dismiss(animated: true) {

                if (self.editState) {
                
                    let realEstateImage = RealEstateImages(context: self.dataController.viewContext)
                    realEstateImage.creationDate = Date()
                    realEstateImage.image = image.jpegData(compressionQuality: CGFloat(integerLiteral: 50))
                    realEstateImage.realEstateProperty = self.realEstatePropertyToEdit
                    self.realEstateImagesArray.append(realEstateImage)
                    
                    self.saveCoreData(controller: self.dataController, completionHandler: { (sucess, error) in
                        if (error != nil) {
                            print("save error:\(String(describing: error?.localizedDescription))")
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    })
                    
                    
                }

            }
            
            

        } else {
            self.alertNotification(message: "There was a problem with the selected image.")
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        present(actionSheet, animated: true, completion: nil)
    }
    
    
}

// MARK:- CustomCellDelegate Methods
extension AddAddressController: CustomCellDelegate  {
    
    func deleteImage(cell: CustomCollectionViewCell) {
        
        if let indexPath = collectionView?.indexPath(for: cell) {
            
            if let imageToDelete = realEstateImagesArray[indexPath.row] as? RealEstateImages {
                
                    realEstateImagesArray.remove(at: indexPath.row)
                    collectionView.deleteItems(at: [indexPath])
                    dataController.viewContext.delete(imageToDelete)
                
                saveCoreData(controller: dataController) { (success, error) in
                    if (error != nil) {
                        print("save error:\(String(describing: error?.localizedDescription))")
                    }
                }
                
            }
            
        }
        
    }
    
    
    private func isDeleteNotesButtonHidden(localEditState:Bool, deleteBtn:UIButton) {
        if (localEditState == true) {
            if ((realEstatePropertyToEdit.note?.isEmpty)! || realEstatePropertyToEdit.note == "") {
                deleteBtn.isHidden = true
            } else {
                deleteBtn.isHidden = isCollectionViewInEditingMode
            }
        } else {
            deleteBtn.isHidden = true
        }
    }
    
}











