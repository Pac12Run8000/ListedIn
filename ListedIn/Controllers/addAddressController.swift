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
        
        addresses = ["San Antonio TX", "Houston TX", "Dallas TX", "Austin TX", "New Haven CT", "New York, NY", "Detroit, MI", "Chicago IL"]
        
        view.backgroundColor = UIColor.darkgreen
        searchBarOutlet.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    

    
    

}


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
        } else {
            cell.textLabel?.text = addresses[indexPath.row]
        }
        return cell
    }
    
    
}


// MARK:- SearchBar Delegate
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
}
