//
//  WeatherViewModel.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/18/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreLocation
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

    self.locationService.delegate = self
    self.apiClient.delegate = self
  }

  public func getfilteredCities(searchText: String) -> [City] {
    return self.database.filteredCities(searchText: searchText)
  }

  public func requestLocationPermissionIfNecessary() {
    if !self.locationService.canAccessLocation &&
      !self.locationService.locationAccessDenied {
      self.locationService.requestAccess()
    }
  }
}

extension WeatherViewModel: LocationServiceDelegate {
  func locationSet(to location: CLLocation) {
    // FIXME: Get the weather for that location
    self.apiClient.getForecastFor(location: location, timestamp: 0)
  }

  func locationStringSet(to _: String) {
    // FIXME: Do something with this string
  }
}

extension WeatherViewModel: ApiClientDelegate {
  func apiClientGotError(_ error: Error) {
    // FIXME: Show this error to the user
    print("ERROR: \(String(describing: self)) \(#line) \(error.localizedDescription)")
  }

  func apiClientGotForecast(_: Forecast) {
    // FIXME: Send this data to the view using Combine
  }
}
