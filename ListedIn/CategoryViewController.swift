//
//  ViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/14/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    var categoryTextField:UITextField?
    
    var categories = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTheDelegateAndDataSource()
        setDynamicRowHeight()
        
        navigationController?.navigationBar.barTintColor = UIColor.darkgreen
        navigationController?.navigationBar.tintColor = UIColor.brightGreen_2
        
    }
    
    @IBAction func addCategoryButtonAction(_ sender: Any) {
       categoryAlertController()
    }
    


}


// MARK:- This is where you'll find all tableView and tableviewcell rendering functionality
extension CategoryViewController:UITableViewDataSource, UITableViewDelegate {
    
    func setDynamicRowHeight() {
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    func setTheDelegateAndDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = categories[indexPath.row]
        cell.detailTextLabel?.text = ""
        cell.backgroundColor = UIColor.greenCyan
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    
}





// MARK: This is where the alertController gets the category name that is to be passed to CoreData
extension CategoryViewController {
    
    func categoryAlertController() {
        let alertDialog = UIAlertController(title: "", message: "Enter a category for your list.", preferredStyle: .alert)
        
        let cancelDialog = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveDialog = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            
            if let category = self?.categoryTextField?.text {
                self?.addCategory(catagory: category)
            }
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
 
    
    func addCategory(catagory:String)  {
        self.categories.append(catagory)
        let indexPath = IndexPath(row: self.categories.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
}

