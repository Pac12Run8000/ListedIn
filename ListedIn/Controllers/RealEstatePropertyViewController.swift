//
//  RealEstatePropertyViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/18/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

//protocol MemeGeneratorViewControllerDelegate:class {
//
//    func memeGeneratorViewControllerDidCancel(_ controller:MemeGeneratorViewController)
//    func memeGeneratorViewController(_ controller:MemeGeneratorViewController, didFinishAdding item:(topText: String, bottomText: String, originalImage: NSData, memedImage: NSData))
//    func memeGeneratorViewController(_ controller:MemeGeneratorViewController, didFinishEditing item:MemeObj)
//
//}

protocol RealEststeNoteDelegate:class {
    

}

class RealEstatePropertyViewController: UIViewController {
    
    var addresses:[Address] = [Address]()
    
    var dataController:DataController!
    var category:Category!
    @IBOutlet weak var tableView: UITableView!
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setupTableViewProperties()
        
        addresses = test_data_populateWithAddresses()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    
    
   
    
   

}



// MARK:- TableViewDelegate and TableViewDataSource
extension RealEstatePropertyViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = addresses[indexPath.row].name
        cell.backgroundColor = UIColor.greenCyan
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}

// MARK:- TableView properties like cellsize, datasource, delegate, backgroundColor, etc
extension RealEstatePropertyViewController {
    
    private func setupTableViewProperties() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorColor = UIColor.darkgreen
        tableView.backgroundColor = UIColor.brightGreen_1
    }
    
}

// MARK:- Dummy address array data
extension RealEstatePropertyViewController {
    
    private func test_data_populateWithAddresses() -> [Address] {
        
        var addressArray = [Address]()
        let outputaddresses = ["1810 San Jose Ave. Alameda CA 94501", "20284 Fenmore St, Detroit MI", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco", "laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."]
        
        
        
        for item in outputaddresses {
            var address = Address()
            address.name = item
            addressArray.append(address)
        }
        
        
        return addressArray
    }
}
