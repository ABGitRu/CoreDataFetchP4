//
//  PriceInfo+CoreDataProperties.swift
//  CoreDataFetchP4
//
//  Created by Mac on 23.06.2021.
//
//

import Foundation
import CoreData


extension PriceInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceInfo> {
        return NSFetchRequest<PriceInfo>(entityName: "PriceInfo")
    }

    @NSManaged public var priceCategory: String?
    @NSManaged public var venue: Venue?

}

extension PriceInfo : Identifiable {

}
