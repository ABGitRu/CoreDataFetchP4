//
//  FilterViewController.swift
//  CoreDataFetchP4
//
//  Created by Mac on 23.06.2021.
//

import UIKit
import CoreData


protocol FilterViewControllerDelegate: class {
    func filterViewController (
        filter: FilterViewController,
        didSelectPredicate predicate: NSPredicate?,
        sortDescriptor: NSSortDescriptor?
    )
}

class FilterViewController: UITableViewController {
    
    @IBOutlet weak var firstPriceCategoryLabel: UILabel!
    @IBOutlet weak var secondPriceCategoryLabel: UILabel!
    @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
    @IBOutlet weak var numDealsLabel: UILabel!
    
    // MARK: - Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!
    
    // MARK: - Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    @IBOutlet weak var userTipsCell: UITableViewCell!
    
    // MARK: - Sort section
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var nameZASortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    var coreDataStack: CoreDataStack?
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedPredicate: NSPredicate?
    var selectedSortDesctriptor: NSSortDescriptor?
    
    lazy var cheapVenuesPredicate: NSPredicate = {
        NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
    }()
    
    lazy var moderateVenuesPredicate: NSPredicate = {
        NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    }()
    
    lazy var expensiveVenuesPredicate: NSPredicate = {
        NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
    }()
    
    lazy var offeringDealPredicate: NSPredicate = {
        NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
    }()
    
    lazy var walkingDistancePredicate: NSPredicate = {
        NSPredicate(format: "%K < 500", #keyPath(Venue.location.distance))
    }()
    
    lazy var hasUserTipsPredicate: NSPredicate = {
        NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
    }()
    
    lazy var nameSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Venue.name), ascending: true, selector: compareSelector)
    }()
    
    lazy var distanceSortDescriptor: NSSortDescriptor = {
        NSSortDescriptor(key: #keyPath(Venue.location.distance), ascending: true)
    }()
    
    lazy var priceSortDescriptor: NSSortDescriptor = {
        NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory), ascending: true)
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCheapVenues()
        fetchModerateVenues()
        fetchExpensiveVenues()
        populateCountDeals()
    }
    
}

// MARK: - IBActions
extension FilterViewController {
    
    @IBAction func search(_ sender: UIBarButtonItem) {

        delegate?.filterViewController(filter: self,
                                       didSelectPredicate: selectedPredicate,
                                       sortDescriptor: selectedSortDesctriptor)
        dismiss(animated: true)
        
    }
}

// MARK - UITableViewDelegate
extension FilterViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        switch cell {
        case cheapVenueCell:
            selectedPredicate = cheapVenuesPredicate
        case moderateVenueCell:
            selectedPredicate = moderateVenuesPredicate
        case expensiveVenueCell:
            selectedPredicate = expensiveVenuesPredicate
            
        case offeringDealCell:
            selectedPredicate = offeringDealPredicate
        case walkingDistanceCell:
            selectedPredicate = walkingDistancePredicate
        case userTipsCell:
            selectedPredicate = hasUserTipsPredicate
            
            
        case nameAZSortCell:
            selectedSortDesctriptor = nameSortDescriptor
        case nameZASortCell:
            selectedSortDesctriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
        case distanceSortCell:
            selectedSortDesctriptor = distanceSortDescriptor
        case priceSortCell:
            selectedSortDesctriptor = priceSortDescriptor
        default: break
        }
        cell.accessoryType = .checkmark
    }
}

extension FilterViewController {
    func fetchCheapVenues() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = cheapVenuesPredicate
        
        do {
            let countResults = try coreDataStack?.managedContext.fetch(fetchRequest)
            let count = countResults?.first?.intValue ?? 0
            let pluralized = count == 1 ? "Место" : "Мест"
            firstPriceCategoryLabel.text = "\(count) \(pluralized) с пузырьковым чаем"
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    func fetchModerateVenues() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = moderateVenuesPredicate
        
        do {
            let countResults = try coreDataStack?.managedContext.fetch(fetchRequest)
            let count = countResults?.first?.intValue ?? 0
            let pluralized = count == 1 ? "Место" : "Мест"
            secondPriceCategoryLabel.text = "\(count) \(pluralized) с пузырьковым чаем"
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    func fetchExpensiveVenues() {
        let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest.predicate = expensiveVenuesPredicate
        do {
            let count = try coreDataStack?.managedContext.count(for: fetchRequest)
            let pluralized = count == 1 ? "Место" : "Мест"
            thirdPriceCategoryLabel.text = "\(count ?? 0) \(pluralized) с пузырьковым чаем"
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    func populateCountDeals() {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
        fetchRequest.resultType = .dictionaryResultType
        
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"
        
        let specialCountExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp])
        
        sumExpressionDesc.expressionResultType = .integer32AttributeType
        
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        
        do {
            let results = try coreDataStack?.managedContext.fetch(fetchRequest)
            let resultsDict = results?.first
            let sumDeals = resultsDict?["sumDeals"] as? Int ?? 0
            let pluralized = sumDeals == 1 ? "deal" : "deals"
            numDealsLabel.text = "\(sumDeals) \(pluralized)"
        } catch let error {
            print(error)
        }
    }
}

