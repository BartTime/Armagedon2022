//
//  BasketForDestruction+CoreDataProperties.swift
//  Armagedon2022
//
//  Created by Alex on 16.04.2022.
//
//

import Foundation
import CoreData


extension BasketForDestruction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BasketForDestruction> {
        return NSFetchRequest<BasketForDestruction>(entityName: "BasketForDestruction")
    }
    @NSManaged public var linkToAsteroid: String?
    @NSManaged public var index: Int16
}

extension BasketForDestruction : Identifiable {

}
