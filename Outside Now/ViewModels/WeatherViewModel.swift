//
//  WeatherViewModel.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/18/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

final class WeatherViewModel {
  public let database: Database
  public let locationService: LocationService
  public let apiClient: ApiClient

  init(
    database: Database = Database(),
    locationService: LocationService = LocationService(),
    apiClient: ApiClient = ApiClient()
  ) {
    self.database = database
    self.locationService = locationService
    self.apiClient = apiClient

    if self.database.isEmpty {
      self.database.addCities()
    }
  }

  public func getfilteredCities(searchText: String) -> [City] {
    return database.filteredCities(searchText: searchText)
  }

  public func requestLocationPermissionIfNecessary() {
    if !self.locationService.canAccessLocation &&
      !self.locationService.locationAccessDenied {
      self.locationService.requestAccess()
    }
  }
}
