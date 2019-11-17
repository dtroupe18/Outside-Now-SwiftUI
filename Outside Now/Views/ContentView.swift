//
//  ContentView.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/16/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let array = ["Peter", "Paul", "Mary", "Anna-Lena", "George", "John", "Greg", "Thomas", "Robert", "Bernie", "Mike", "Benno", "Hugo", "Miles", "Michael", "Mikel", "Tim", "Tom", "Lottie", "Lorrie", "Barbara"]

    @State private var searchText = ""
    @State private var searchIsActive: Bool = false
    @Environment(\.managedObjectContext) var context

    // @FetchRequest(fetchRequest: City.autoCompleteFetchRequest(searchText: searchText)) var cities: FetchedResults<City>
    @FetchRequest(fetchRequest: City.allCitiesFetchRequest()) var allCities: FetchedResults<City>

    private let database = Database()

    var body: some View {
        NavigationView {
            VStack {
                // Search view
                SearchBar(searchText: $searchText, isActive: $searchIsActive)

                // if searchIsActive {
                    List {
                        // Filtered list of cities
                        ForEach(self.allCities.filter { $0.name.contains(searchText) }) {  city in
                            Text("\(city.name), \(city.state)")
                        }
                    }
                    .resignKeyboardOnDragGesture()
                // }
            }
            .modifier(HideNavigationBar())
        }.onAppear(perform: {
            if self.database.isEmpty {
                print("core data is empty")
                self.database.addCities()
            } else {
                print("core data is not empty")
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           ContentView()
              .environment(\.colorScheme, .light)

           ContentView()
              .environment(\.colorScheme, .dark)
        }
    }
}
