//
//  WeatherViewModel.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/18/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreLocation
import Foundation

// FIXME: Make this conform to a protocol.

final class WeatherViewModel {
  public let database: CityDatabaseProtocol
  public let locationService: LocationService
  public let apiClient: ApiClient
  public let logger: Logger

  init(
    database: CityDatabaseProtocol,
    locationService: LocationService,
    apiClient: ApiClient,
    logger: Logger
  ) {
    self.database = database
    self.locationService = locationService
    self.apiClient = apiClient
    self.logger = logger

    if !self.database.isFull {
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
  func locationPermissionDenied() {
    // FIXME: Show an error to the user!
  }

  func locationUpdated(to location: CLLocation) {
    self.apiClient.getForecastFor(location: location, timestamp: 0)
  }
}

extension WeatherViewModel: ApiClientDelegate {
  func apiClientGotError(_ error: Error) {
    // FIXME: Show this error to the user
    self.logger.logError(error)
  }

  func apiClientGotForecast(_: Forecast) {
    // FIXME: Send this data to the view using Combine
  }
}
