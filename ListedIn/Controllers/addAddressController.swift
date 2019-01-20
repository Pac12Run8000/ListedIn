//
//  addAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class addAddressController: UIViewController {
    
    var addresses:[String]!
    var addressPredictions:[String] = [String]()
    var isSearching:Bool = false

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addresses = ["Current Location", "San Antonio TX", "Houston TX", "Dallas TX", "Austin TX", "New Haven CT", "New York, NY", "Detroit, MI", "Chicago IL"]
        
        view.backgroundColor = UIColor.darkgreen
        
        
        searchBarOutlet.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    

    
    

}

// MARK: UITableViewDelegate methods
extension addAddressController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return addressPredictions.count
        } else {
            return addresses.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isSearching {
            cell.textLabel?.text = addressPredictions[indexPath.row]
            cell.textLabel?.textColor = addressPredictions[indexPath.row] == "Current Location" ? UIColor.greenCyan : UIColor.black
        } else {
            cell.textLabel?.text = addresses[indexPath.row]
            cell.textLabel?.textColor = addresses[indexPath.row] == "Current Location" ? UIColor.greenCyan : UIColor.black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            searchBarOutlet.text = addressPredictions[indexPath.row]
        } else {
            searchBarOutlet.text = addresses[indexPath.row]
        }
    }
    
    
}


// MARK:- SearchBar Delegate Methods
extension addAddressController: UISearchBarDelegate {
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true) {
            self.isSearching = false
            self.searchBarOutlet.text = ""
        }
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        addressPredictions = addresses.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.text = "Current Location"
        }
    }
}
