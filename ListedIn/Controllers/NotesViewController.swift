//
//  NotesViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 2/11/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    var realEstateProperty:RealEstateProperty! = nil
    var dataController:DataController!
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    @IBOutlet weak var labelHeightOutlet: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.greenCyan
        setupNotesTextField()
        errorMsglayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch dataController {
        case .none:
            print("The dataController is nil")
        case .some:
            print("There is a dataController")
            
        }
        

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
            navigationController?.popViewController(animated: true)
        }
        return true
    }
    
    
}
