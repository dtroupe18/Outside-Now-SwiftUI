//
//  Database.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import UIKit
import CoreData

final class Database {
    private let csvFilename: String = "US-Cities-Clean"
    private let csvExt: String = ".csv"
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private func autoCompleteFetchRequest(searchText: String) -> NSFetchRequest<City> {
        let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
        let predicate = NSPredicate(format: "name BEGINSWITH %@", searchText)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 20 // FIXEME: Does this actually work?
        return request
    }

    func filteredCities(searchText: String) -> [City] {
        let request = self.autoCompleteFetchRequest(searchText: searchText.lowercased())

        do  {
            return try context.fetch(request)
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

    var isEmpty : Bool {
        do {
            let request: NSFetchRequest<City> = NSFetchRequest(entityName: City.entityName)
            let count  = try self.context.count(for: request)
            return count == 0
        } catch let err {
            // FIXME: Log for realz
            print("ERROR: \(err)")
            return true
        }
    }

    func addCities() {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        privateContext.perform { [weak self] in
            // Code in here is now running "in the background"

            let start = Date()
            guard let sself = self else { return }
            guard let data = sself.readDataFromCSV() else { fatalError() } // FIXME: Remove fatal error

            let rows = data.components(separatedBy: "\n")
            for row in rows where !row.isEmpty {
                let columns = row.components(separatedBy: ",")

                if columns.count == 2 {
                    let city = City(context: sself.context)
                    city.name = columns[0]
                    city.state = columns[1]

                    print("Adding city \(city.name)")

                    do {
                        try privateContext.save()
                        // try sself.context.save()
                    } catch let err {
                        print("ERROR: \(String(describing: self)) \(#line) \(err.localizedDescription)")
                    }
                } else {
                    // FIXME: Remove
                    fatalError()
                }
            }

            let end = Date()
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([ .second])
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
