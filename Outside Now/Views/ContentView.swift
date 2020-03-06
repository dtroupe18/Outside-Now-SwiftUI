//
//  ContentView.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/16/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreData
import CoreLocation
import SwiftUI

struct ContentView: View {
  @State private var searchText = ""
  @State private var searchIsActive: Bool = false
  @Environment(\.managedObjectContext) var context

  private var listOpacity: Double {
    return self.searchIsActive ? 1.0 : 0.0
  }

  private var nonListOpacity: Double {
    return self.searchIsActive ? 0.0 : 1.0
  }

  @State private var waitingForLocation: Bool = true

  private let viewModel: WeatherViewModel // FIXME: We are going to observe this object

  init(viewModel: WeatherViewModel = WeatherViewModel()) {
    self.viewModel = viewModel
  }

//  func filteredCities() -> [City] {
//    return viewModel.getfilteredCities(searchText: searchText)
//  }

  var body: some View {
    NavigationView {
      VStack {
        // Search view
        SearchBar(searchText: $searchText, isActive: $searchIsActive)

        // Use a ZStack so that the list is hidden behind the weather
        // but we can show it when search is activated
        ZStack {
          List {
            // Filtered list of cities
            ForEach(viewModel.getfilteredCities(searchText: searchText)) { city in
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
      self.viewModel.requestLocationPermissionIfNecessary()
    })
  }
}

#if DEBUG
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
#endif
