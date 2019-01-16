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
    
    var categories = [Category]()
    
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


// MARK:- The tableView delegate functions
extension CategoryViewController:UITableViewDataSource, UITableViewDelegate {
    
    func setDynamicRowHeight() {
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    func setTheDelegateAndDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = categories[indexPath.row].name
        cell.detailTextLabel?.text = ""
        cell.backgroundColor = UIColor.greenCyan
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let category = categories[indexPath.row]
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (rowAction, indexPath) in
            self.editCategory(category: category, indexPath: indexPath)
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (rowAction, indexPath) in
            self.deleteCategory(input: category, indexPath: indexPath)
        }
        editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        return [editAction, deleteAction]
    }
    
    
}

// MARK:- Adding, Updating and Deleting data from the Categories array
extension CategoryViewController {
    
    private func editCategory(category:Category, indexPath:IndexPath) {
        let alert = UIAlertController(title: "", message: "Update the category", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let textField = alert.textFields?.first else {
                return
            }
            
            guard let textToEdit = textField.text, textToEdit.count != 0 else {
                return
            }
            
            category.name = textToEdit
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField()
        guard let textField = alert.textFields?.first else {
            return
        }
        textField.placeholder = "Update category"
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteCategory(input:Category, indexPath:IndexPath) {
        self.categories.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func addCategoryToTableViewAndArray(catagory:Category)  {
        self.categories.insert(catagory, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .left)
    }
}





// MARK: AlertController functionality
extension CategoryViewController {
    
    func categoryAlertController() {
        let alertDialog = UIAlertController(title: "", message: "Enter a category for your list.", preferredStyle: .alert)
        
        let cancelDialog = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveDialog = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            
            if let categoryName = self?.categoryTextField?.text {
                let myCat = Category()
                myCat.name = categoryName
                self?.addCategoryToTableViewAndArray(catagory: myCat)
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
 
    
    
    
}


