//
//  ViewController.swift
//  CoreDataFetchP4
//
//  Created by Mac on 23.06.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let filterViewControllerSegueIdentifier = "toFilterViewController"
    private let venueCellIdentifier = "VenueCell"
    
    var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest<Venue>?
    var venues: [Venue] = []
    
    var assyncFetchRequest: NSAsynchronousFetchRequest<Venue>?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRequest = Venue.fetchRequest()
        fetchCafe()
        
//        let venueFetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
//
//        assyncFetchRequest = NSAsynchronousFetchRequest<Venue>(fetchRequest: venueFetchRequest) {
//            [unowned self] (result: NSAsynchronousFetchResult) in
//            guard let venues = result.finalResult else { return }
//
//            self.venues = venues
//            self.tableView.reloadData()
//        }
//
//        do {
//            guard let asyncFetchRequest = assyncFetchRequest else { return }
//            try coreDataStack.managedContext.execute(asyncFetchRequest)
//        } catch let error {
//            print(error)
//        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == filterViewControllerSegueIdentifier,
              let navVC = segue.destination as? UINavigationController,
              let filterVC = navVC.topViewController as? FilterViewController
        else { return }
        
        filterVC.coreDataStack = coreDataStack
        filterVC.delegate = self
    }
    
    private func fetchCafe() {
        guard let fetchRequest = fetchRequest else { return }
        
        do {
            venues = try coreDataStack.managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
}

// MARK: - IBActions
extension ViewController {
    
    @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
        let venue = venues[indexPath.row]
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
        return cell
    }
}


extension ViewController: FilterViewControllerDelegate {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        guard let fetchRequest = fetchRequest else { return }
        
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil
        
        fetchRequest.predicate = predicate
        
        if let sort = sortDescriptor {
            fetchRequest.sortDescriptors = [sort]
        }
        
        fetchCafe()
    }
}
