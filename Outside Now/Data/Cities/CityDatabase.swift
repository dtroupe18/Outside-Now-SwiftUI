//
//  CityDatabase.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreData
import Crashlytics
import UIKit

protocol CityDatabaseProtocol {
  var isFull: Bool { get }

  init(logger: Logger, context: NSManagedObjectContext)

  func filteredCities(searchText: String) -> [City]
  func initialCities() -> [City]
  func addCities()
}

final class CityDatabase: CityDatabaseProtocol {
  private let csvFilename: String = "US-Cities-Clean"
  private let csvExt: String = ".csv"
  private let context: NSManagedObjectContext
  private let logger: Logger

  init(logger: Logger, context: NSManagedObjectContext) {
    self.logger = logger
    self.context = context
  }

  private var mostPopulatedCitiesFetchRequest: NSFetchRequest<City> {
    let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
    let populationSort = NSSortDescriptor(key: "population", ascending: false)

    request.sortDescriptors = [populationSort]
    request.fetchLimit = 20
    return request
  }

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
      self.logger.logError(err)
      return []
    }
  }

  func initialCities() -> [City] {
    let request = self.mostPopulatedCitiesFetchRequest

    do {
      return try self.context.fetch(request)
    } catch let err {
      self.logger.logError(err)
      return []
    }
  }

  var isFull: Bool {
    do {
      let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
      let count = try context.count(for: request)
      return count == 28889 // last row is blank
    } catch let err {
      self.logger.logError(err)
      return true
    }
  }

  func addCities() {
    let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateContext.persistentStoreCoordinator = self.context.persistentStoreCoordinator
    privateContext.perform { [weak self] in
      // Code in here is now running "in the background"

      let start = Date()
      guard let sself = self, let data = sself.readDataFromCSV() else { return }

      let rows = data.components(separatedBy: "\n")
      for row in rows where !row.isEmpty {
        let columns = row.components(separatedBy: ",")

        if columns.count == 6 {
          let city = City(context: privateContext)
          city.name = columns[0].lowercased()
          city.state = columns[1].lowercased()

          // swiftlint:disable:next force_unwrapping
          city.latitude = Double(columns[2])!

          // swiftlint:disable:next force_unwrapping
          city.longitude = Double(columns[3])!

          // swiftlint:disable:next force_unwrapping
          city.population = Int64(columns[4])!

        } else {
          let userInfo = [
            NSLocalizedDescriptionKey: "\(String(describing: self)).addCities.incorrectColumnCountError"
          ]

          let err = NSError(domain: "", code: 44561, userInfo: userInfo)
          sself.logger.logError(err, additionalInfo: [
            "columns": columns
          ])
        }
      }

      do {
        try privateContext.save()
      } catch let err {
        sself.logger.logError(err)
      }

      let end = Date()
      let calendar = Calendar.current
      let unitFlags = Set<Calendar.Component>([.second])
      let datecomponents = calendar.dateComponents(unitFlags, from: start, to: end)
      let seconds = datecomponents.second

      sself.logger.logDebug("Finished saving all cities to core data in \(String(describing: seconds))")
    }
  }

  private func readDataFromCSV() -> String? {
    // swiftlint:disable:next force_unwrapping
    let filepath = Bundle.main.path(forResource: self.csvFilename, ofType: self.csvExt)! // covered by tests

    do {
      return try String(contentsOfFile: filepath, encoding: .utf8)
    } catch let err {
      self.logger.logError(err)
      return nil
    }
  }
}
