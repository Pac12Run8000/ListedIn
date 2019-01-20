//
//  addAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class addAddressController: UIViewController {
    
    var addresses:[Address]!
    var addressPredictions:[Address] = [Address]()
    var isSearching:Bool = false

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = UIColor.darkgreen
        
        
        searchBarOutlet.delegate = self
        searchBarOutlet.becomeFirstResponder()
        
       
        
        tableView.delegate = self
        tableView.dataSource = self
        addresses = populateAddressArray()
        
    }
    
    private func populateAddressArray() -> [Address] {
        var addressArray = [Address]()
        var addresses = ["Current Location", "San Antonio TX", "Houston TX", "Dallas TX", "Austin TX", "New Haven CT", "New York, NY", "Detroit, MI", "Chicago IL"]
        
        for item in addresses {
            var myAddress = Address()
            myAddress.name = item
            addressArray.append(myAddress)
        }
        return addressArray
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
            cell.textLabel?.text = addressPredictions[indexPath.row].name
            cell.textLabel?.textColor = addressPredictions[indexPath.row].name == "Current Location" ? UIColor.greenCyan : UIColor.black
        } else {
            cell.textLabel?.text = addresses[indexPath.row].name
            cell.textLabel?.textColor = addresses[indexPath.row].name == "Current Location" ? UIColor.greenCyan : UIColor.black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            searchBarOutlet.text = addressPredictions[indexPath.row].name
        } else {
            searchBarOutlet.text = addresses[indexPath.row].name
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
        addressPredictions = addresses.filter({ (place:Address) -> Bool in
            place.name!.lowercased().prefix(searchText.count) == searchText.lowercased()
        })
        isSearching = true
        tableView.reloadData()
    }
    
    
}
