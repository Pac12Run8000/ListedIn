//
//  addAddressController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/19/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class addAddressController: UIViewController {
    
    var addressPredictions:[String]!

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressPredictions = ["San Antonio TX", "Houston TX", "Dallas TX", "Austin TX", "New Haven CT", "New York, NY", "Detroit, MI", "Chicago IL"]
        
        view.backgroundColor = UIColor.darkgreen
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    

    
    

}


extension addAddressController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressPredictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = addressPredictions[indexPath.row]
        return cell
    }
    
    
}


// MARK:- Button attributes are set up here
extension addAddressController {
    
}
