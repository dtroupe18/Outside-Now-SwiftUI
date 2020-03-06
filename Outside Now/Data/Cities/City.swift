//
//  City.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/16/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreData
import Foundation

public final class City: NSManagedObject, Identifiable {
  static var entityName: String = "City"

  @NSManaged public var name: String
  @NSManaged public var state: String
  @NSManaged public var population: Int64
}
