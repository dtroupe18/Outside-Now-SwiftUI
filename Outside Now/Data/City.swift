//
//  City.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/16/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation
import CoreData

public final class City: NSManagedObject, Identifiable {
    @NSManaged public var name: String
    @NSManaged public var state: String
}

// MARK: AutoComplete fetch request
extension City {
    static var entityName: String = "City"

    static func autoCompleteFetchRequest(searchText: String) -> NSFetchRequest<City> {
        let request: NSFetchRequest<City> = NSFetchRequest(entityName: "City")
        let predicate = NSPredicate(format: "name CONTAINS %@", searchText)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 20
        return request
    }

    static func allCitiesFetchRequest() -> NSFetchRequest<City> {
        let request: NSFetchRequest<City> = NSFetchRequest(entityName: "City")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        request.sortDescriptors = [sortDescriptor]
        return request
    }
}
