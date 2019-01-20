//
//  addAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class addAddressController: UIViewController {

    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkgreen
        
        setupCancelButton()
        
        
        
    }
    

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension addAddressController {
    private func setupCancelButton() {
        cancelButtonOutlet.layer.borderColor = UIColor.brightGreen_1.cgColor
        cancelButtonOutlet.layer.borderWidth = 3
        cancelButtonOutlet.layer.masksToBounds = true
        cancelButtonOutlet.tintColor = UIColor.brightGreen_1
        cancelButtonOutlet.setTitle("cancel", for: .normal)
    }
}
