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
  @State private var searchText = ""
  @State private var searchIsActive: Bool = false
  @Environment(\.managedObjectContext) var context

  private let database: Database
  private let locationService: LocationService

  private var listOpacity: Double {
    return searchIsActive ? 1.0 : 0.0
  }

  private var nonListOpacity: Double {
    return searchIsActive ? 0.0 : 1.0
  }

  init(
    database: Database = Database(),
    locationService: LocationService = LocationService()
  ) {
    self.database = database
    self.locationService = locationService
  }

  func filteredCities() -> [City] {
    return database.filteredCities(searchText: searchText)
  }

  var body: some View {
    NavigationView {
      VStack {
        // Search view
        SearchBar(searchText: $searchText, isActive: $searchIsActive)

        ZStack {
          List {
            // Filtered list of cities
            ForEach( filteredCities() ) {  city in
              Text("\(city.name.capitalized), \(city.state.uppercased())")
            }
          }
          .resignKeyboardOnDragGesture()
          .opacity(listOpacity)

          LocationCurrentWeatherView()
          .opacity(nonListOpacity)
        }
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
