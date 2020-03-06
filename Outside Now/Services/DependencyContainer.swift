//
//  DependencyContainer.swift
//  Outside Now
//
//  Created by Dave Troupe on 3/6/20.
//  Copyright © 2020 High Tree Development. All rights reserved.
//

import CoreData
import UIKit

typealias Factory = DependencyContainerProtocol & ViewFactoryProtocol

protocol ViewFactoryProtocol {
  func makeContentView() -> ContentView
}

protocol DependencyContainerProtocol {
  var logger: Logger { get }
  var cityDatabase: CityDatabaseProtocol { get }
  var coreDataContainer: CoreDataContainerProtocol { get }
  var apiClient: ApiClient { get }
  var locationService: LocationService { get }
  var weatherViewModel: WeatherViewModel { get }
  var fileService: FileService { get }
}

final class DependencyContainer: DependencyContainerProtocol {
  let coreDataContainer: CoreDataContainerProtocol = CoreDataContainer()
  let logger: Logger = Logger()
  let fileService = FileService()

  private lazy var urlSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 15 // seconds
    configuration.timeoutIntervalForResource = 30
    return URLSession(configuration: .default)
  }()

  private(set) lazy var apiClient: ApiClient = {
    ApiClient(
      urlSession: self.urlSession,
      logger: self.logger,
      fileService: self.fileService
    )
  }()

  private(set) lazy var cityDatabase: CityDatabaseProtocol = CityDatabase(
    logger: self.logger,
    context: self.coreDataContainer.persistentContainer.viewContext
  )

  private(set) lazy var locationService: LocationService = {
    LocationService(logger: self.logger)
  }()

  private(set) lazy var weatherViewModel: WeatherViewModel = {
    WeatherViewModel(
      database: self.cityDatabase,
      locationService: self.locationService,
      apiClient: self.apiClient,
      logger: self.logger
    )
  }()
}

// MARK: ViewFactory

extension DependencyContainer: ViewFactoryProtocol {
  func makeContentView() -> ContentView {
    return ContentView(factory: self)
  }
}
