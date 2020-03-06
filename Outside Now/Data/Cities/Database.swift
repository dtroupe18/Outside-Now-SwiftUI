//
//  Database.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreData
import UIKit

final class Database {
  private let csvFilename: String = "US-Cities-Clean"
  private let csvExt: String = ".csv"

  // swiftlint:disable:next force_cast
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  private func autoCompleteFetchRequest(searchText: String) -> NSFetchRequest<City> {
    let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
    let predicate = NSPredicate(format: "name BEGINSWITH %@", searchText)
    let nameSort = NSSortDescriptor(key: "name", ascending: true)
    let populationSort = NSSortDescriptor(key: "population", ascending: false)

    request.predicate = predicate
    request.sortDescriptors = [populationSort, nameSort]
    request.fetchLimit = 20 // FIXEME: Does this actually work?
    return request
  }

  func filteredCities(searchText: String) -> [City] {
    let request = self.autoCompleteFetchRequest(searchText: searchText.lowercased())

    do {
      return try self.context.fetch(request)
    } catch let err {
      // FIXME:
      print(err.localizedDescription)
      return []
    }
  }

  // FIXME: Remove this only good for debugging
  func allCitiesFetchRequest() -> NSFetchRequest<City> {
    let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

    request.sortDescriptors = [sortDescriptor]
    return request
  }

  // FIXME: Check if the database if full rather than just empty
  var isEmpty: Bool {
    do {
      let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
      let count = try self.context.count(for: request)
      return count == 0
    } catch let err {
      // FIXME: Log for realz
      print("ERROR: \(err)")
      return true
    }
  }

  // FIXME: Optimize for partial creation
  func addCities() {
    let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateContext.persistentStoreCoordinator = self.context.persistentStoreCoordinator
    privateContext.perform { [weak self] in
      // Code in here is now running "in the background"

      let start = Date()
      guard let sself = self else { return }
      guard let data = sself.readDataFromCSV() else { fatalError() } // FIXME: Remove fatal error

      let rows = data.components(separatedBy: "\n")
      for row in rows where !row.isEmpty {
        let columns = row.components(separatedBy: ",")

        if columns.count == 3 {
          let city = City(context: privateContext)
          city.name = columns[0]
          city.state = columns[1]
          // swiftlint:disable:next force_unwrapping
          city.population = Int64(columns[2])! // FIXME: Test this force unwrap
        } else {
          // FIXME: Remove
          fatalError()
        }
      }

      do {
        try privateContext.save()
      } catch let err {
        print("ERROR: \(String(describing: self)) \(#line) \(err.localizedDescription)")
      }

      let end = Date()
      let calendar = Calendar.current
      let unitFlags = Set<Calendar.Component>([.second])
      let datecomponents = calendar.dateComponents(unitFlags, from: start, to: end)
      let seconds = datecomponents.second
      print("Finished saving all cities to core data in \(String(describing: seconds))")
    }
  }

  private func readDataFromCSV() -> String? {
    // FIXME: Test this
    let filepath = Bundle.main.path(forResource: self.csvFilename, ofType: self.csvExt)!

    do {
      return try String(contentsOfFile: filepath, encoding: .utf8)
    } catch let err {
      // FIXME: Log this error
      print("ERROR: \(String(describing: self)) \(#line) \(err.localizedDescription)")
      return nil
    }
  }
}
