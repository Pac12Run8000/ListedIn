//
//  ViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/14/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    //
    var categoryTextField:UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addCategoryButtonAction(_ sender: Any) {
       categoryAlertController()
    }
    


}





// MARK: This is where the alertController gets the category name that is to be passed to CoreData
extension CategoryViewController {
    
    
    func categoryAlertController() {
        let alertDialog = UIAlertController(title: "", message: "Enter a category for your list.", preferredStyle: .alert)
        
        let cancelDialog = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveDialog = UIAlertAction(title: "Save", style: .default) { (action) in
            
            print("Category:\(String(describing: self.categoryTextField?.text))")
            
        }
        saveDialog.isEnabled = false
        alertDialog.addAction(saveDialog)
        alertDialog.addAction(cancelDialog)
        
        
        alertDialog.addTextField { (textField) in
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { (notification) in
                if let text = textField.text, !text.isEmpty, text != "" {
                    saveDialog.isEnabled = true
                } else {
                    saveDialog.isEnabled = false
                }
            })
            self.categoryTextField?.placeholder = "category"
            self.categoryTextField = textField
        }
        present(alertDialog, animated: true, completion: nil)
    }
    
}

