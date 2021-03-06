//
//  RealEstatePropertyViewController.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/18/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class RealEstatePropertyViewController: UIViewController {
    
    var dataController:DataController!
    var category:Category!
    var fetchedResultsController:NSFetchedResultsController<RealEstateProperty>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupfetchedResultsController()
    }

}


// MARK:- AddAddressControllerDelegate functionality
extension RealEstatePropertyViewController: AddAddressControllerDelegate {
    
    func AddAddressController(_ controller: AddAddressController, didFinishEditing item: RealEstateProperty?) {
        updateRealEstate(realEstate:item!)
        navigationController?.popViewController(animated: true)
    }
    
    
    func AddAddressController(_ controller: AddAddressController, didFinishAdding item: (address: String?, coordinate: CLLocationCoordinate2D?)) {
        saveRealEstate(address: item.address, coordinate: item.coordinate)
        navigationController?.popViewController(animated: true)
    }
    
}



// MARK: PrepareForSegue
extension RealEstatePropertyViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAddresSegue" {
            let control = segue.destination as! AddAddressController
            control.addressDelegate = self 
        } else if segue.identifier == "editAddresSegue" {
            let control = segue.destination as! AddAddressController
            control.dataController = dataController
            control.addressDelegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                control.realEstatePropertyToEdit = fetchedResultsController.object(at: indexPath)
            }
        }
    }
    
    
}



// MARK:- TableViewDelegate and TableViewDataSource
extension RealEstatePropertyViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realEstate = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = realEstate.address
        cell.backgroundColor = UIColor.greenCyan
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (rowAction, indexPath) in
            
            self.deleteRealEstate(at: indexPath)
        }
        deleteAction.backgroundColor = UIColor.darkgreen
        return [deleteAction]
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

// MARK:- CoreData functionality
extension RealEstatePropertyViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    private func updateRealEstate(realEstate:RealEstateProperty) {
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("CoreData failed to save.")
        }
    }
    
    private func saveRealEstate(address:String?, coordinate:CLLocationCoordinate2D?) {
        let realEstate = RealEstateProperty(context: dataController.viewContext)
        realEstate.address = address
        realEstate.latitude = (coordinate?.latitude)!
        realEstate.longitude = (coordinate?.longitude)!
        realEstate.note = ""
        realEstate.creationDate = Date()
        realEstate.category = category
        do {
            try dataController.viewContext.save()
            print("Data has been saved.")
        } catch {
            print("There was an error:\(error.localizedDescription)")
        }
    }
    
    private func setupfetchedResultsController() {
        let fetchRequest:NSFetchRequest<RealEstateProperty> = RealEstateProperty.fetchRequest()
        let predicate = NSPredicate(format: "category == %@", category)
        fetchRequest.predicate = predicate
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchRequest.sortDescriptors = sortDescriptor
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    private func deleteRealEstate(at indexPath:IndexPath) {
        let realEstate = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(realEstate)
        do {
            try dataController.viewContext.save()
            print("Successful save.")
        } catch {
            print("There was an error:\(error.localizedDescription)")
        }
    }
    

}




