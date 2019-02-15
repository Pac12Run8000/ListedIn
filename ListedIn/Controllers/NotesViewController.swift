//
//  NotesViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 2/11/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData


protocol RealEstatePropertyEditingDelegate:class {
    
    func EditAddressNote(_ controller: UIViewController, didFinishEditing item: RealEstateProperty)
    
}



class NotesViewController: UIViewController {
    
    var realEstateProperty:RealEstateProperty! = nil
    var dataController:DataController!
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    @IBOutlet weak var labelHeightOutlet: NSLayoutConstraint!
    
    weak var realEstateDelegate:RealEstatePropertyEditingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.greenCyan
        setupNotesTextField()
        errorMsglayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        print("RealEstateNote:\(realEstateProperty.note!)")
        
        
//        switch dataController {
//        case .none:
//            print("The dataController is nil")
//        case .some:
//            print("There is a dataController")
//        }
        

    }
    

    

}

// MARK:- Animate errorLabel
extension NotesViewController {
    
    private func animateContstraintForErrorMessage(input:CGFloat, constraintToAnimate: NSLayoutConstraint ) {
        constraintToAnimate.constant = input
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
    }
}

// MARK:- UI Layout
extension NotesViewController {
    
    private func errorMsglayout() {
        labelHeightOutlet.constant = 0
        errorLabelOutlet.layer.cornerRadius = 5
        errorLabelOutlet.layer.masksToBounds = true
    }
    
}

// MARK:- Set up notes textField
extension NotesViewController {
    
    private func setupNotesTextField() {
        textFieldOutlet.delegate = self
        textFieldOutlet.becomeFirstResponder()
        textFieldOutlet.placeholder = "add notes here ..."
        
        if let realEstateProperty = realEstateProperty {
            textFieldOutlet.text = realEstateProperty.note
        }
    }
}


// MARK:- UITextFieldDelegate functionality
extension NotesViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text?.isEmpty)! {
            animateContstraintForErrorMessage(input: 60, constraintToAnimate: labelHeightOutlet)
            errorLabelOutlet.text = "enter a note or press (Back)."
        } else {
            animateContstraintForErrorMessage(input: 0, constraintToAnimate: labelHeightOutlet)
            
            saveNote(noteContent: textField.text!, realEstateProperty: realEstateProperty) { (success, error) in
                if (success!) {
                    print("Note saved successfully!")
                    
                    self.realEstateProperty.note = self.textFieldOutlet.text
                    self.realEstateDelegate?.EditAddressNote(self, didFinishEditing: self.realEstateProperty)
                } else {
                    print("Error:\(String(describing: error?.localizedDescription))")
                }
            }
            
        }
        return true
    }
    
    
    private func saveNote(noteContent:String, realEstateProperty:RealEstateProperty, completionHandler:@escaping(_ success:Bool?,_ err:Error?) -> ()) {
        
        realEstateProperty.note = noteContent
        
        do {
            try dataController.viewContext.save()
            completionHandler(true,nil)
        } catch {
            completionHandler(false, error)
        }
        
        
    }
    
    
}
