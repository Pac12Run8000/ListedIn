//
//  NotesViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 2/11/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    var realEstateProperty:RealEstateProperty!
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.greenCyan
        setupNotesTextField()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let address = realEstateProperty.address else {return}
        print("property address:\(address)")
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

extension NotesViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationController?.popViewController(animated: true)
        return true
    }
    
    
}
