//
//  ViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/14/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    
    var dataController:DataController!

    var categoryTextField:UITextField?
    
    var categories = [Category]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            categories = result
            tableView.reloadData()
            print("Data fetched!!!")
        }
        
        setTheDelegateAndDataSource()
        setDynamicRowHeight()
        
        tableView.separatorColor = UIColor.darkgreen
        tableView.backgroundColor = UIColor.brightGreen_1
        
        navigationController?.navigationBar.barTintColor = UIColor.darkgreen
        navigationController?.navigationBar.tintColor = UIColor.brightGreen_2
        
    }
    
    @IBAction func addCategoryButtonAction(_ sender: Any) {
       addCategory()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
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
            
            if let categoryToDelete = self.categories[indexPath.row] as? Category {
                self.dataController.viewContext.delete(categoryToDelete)
                do {
                    try self.dataController.viewContext.save()
                    print("Deletion successful. Saving context successful.")
                } catch {
                    print("There was an error deleting category.")
                }
            }
            self.deleteCategory(input: category, indexPath: indexPath)
        }
        editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        return [editAction, deleteAction]
    }
    
    
}

// MARK:- Alert Controllers for Adding, Updating and Deleting
extension CategoryViewController {
    
    func addCategory() {
        let alertDialog = UIAlertController(title: "", message: "Enter a category for your list.", preferredStyle: .alert)
        
        let cancelDialog = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveDialog = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            
            if let categoryName = self?.categoryTextField?.text {
                guard let viewContext = self?.dataController.viewContext else {
                    print("There was an error adding a category")
                    return
                }
                let myCat = Category(context: viewContext)
                myCat.name = categoryName
                myCat.creationDate = Date()
                
                do {
                    try self!.dataController.viewContext.save()
                    print("The data was saved!!!")
                } catch {
                    print("There was an error:\(error.localizedDescription)")
                }
                self?.addCategoryToTableViewAndArray(catagory: myCat)
            }
        }
        
        saveDialog.isEnabled = false
        alertDialog.addAction(saveDialog)
        alertDialog.addAction(cancelDialog)
        
        
        alertDialog.addTextField { (textField) in
            textField.placeholder = "add category"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { (notification) in
                if let text = textField.text, !text.isEmpty, text != "" {
                    saveDialog.isEnabled = true
                } else {
                    saveDialog.isEnabled = false
                }
            })
            self.categoryTextField = textField
        }
        present(alertDialog, animated: true, completion: nil)
    }
    
    private func editCategory(category:Category, indexPath:IndexPath) {
        let alert = UIAlertController(title: "", message: "Update the category", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in

            guard let categoryName = self?.categoryTextField?.text else {
                return
            }
            
            self?.updateCategory(category: category, categoryName: categoryName, indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        saveAction.isEnabled = false
        
        alert.addTextField { (textField) in

            textField.text = category.name
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { (notification) in
                    if let text = textField.text, !text.isEmpty, text != "" {
                        saveAction.isEnabled = true
                    } else {
                        saveAction.isEnabled = false
                    }
            })
            self.categoryTextField = textField
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
}

// MARK:- Udate edit and delete functionality
extension CategoryViewController {
    
    private func updateCategory(category:Category, categoryName:String, indexPath:IndexPath) {
        category.name = categoryName
        
        do {
            try dataController.viewContext.save()
        } catch {
            print("An error occurred saving the update:\(error.localizedDescription)")
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
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








