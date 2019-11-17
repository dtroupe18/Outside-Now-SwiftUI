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
    private let csvFilename: String = "US-Cities"
    private let csvExt: String = ".csv"
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
        guard let data = readDataFromCSV() else { fatalError() } // FIXME: Remove fatal error

        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")

            if columns.count == 3 {
                let city = City(context: self.context)
                city.name = columns[0]
                city.state = columns[1]

                do {
                    try self.context.save()
                } catch let err {
                    print("ERROR: \(String(describing: self)) \(#line) \(err.localizedDescription)")
                }
            } else {
                // FIXME: Remove
                fatalError()
            }
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
