//
//  NotesViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 2/11/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    var realEstateProperty:RealEstateProperty! = nil
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.greenCyan
        setupNotesTextField()
        errorMsglayout()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    

    

}

// MARK:- UI Layout
extension NotesViewController {
    
    private func errorMsglayout() {
        errorLabelOutlet.isHidden = true
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == "" || (textField.text?.isEmpty)!) {
            errorLabelOutlet.isHidden = true
        } else {
            errorLabelOutlet.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text?.isEmpty)! {
            errorLabelOutlet.isHidden = false
            errorLabelOutlet.text = "Your note is empty."
        } else {
            errorLabelOutlet.isHidden = true
            navigationController?.popViewController(animated: true)
        }
        return true
    }
    
    
}
