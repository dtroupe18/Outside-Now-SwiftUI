//
//  ApiClient.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreLocation
import Foundation

typealias DataCallback = (Data) -> Void
typealias ErrorCallback = (Error) -> Void

protocol ApiClientDelegate: AnyObject {
  func apiClientGotError(_ error: Error)
  func apiClientGotForecast(_ forecast: Forecast)
}

final class ApiClient {
  weak var delegate: ApiClientDelegate?

  private let path = Bundle.main.path(forResource: "Keys", ofType: "plist")!
  private let baseURL: String = "https://api.darksky.net/forecast/"

  private var cachedForecasts: [String: Forecast] = [:] // FIXME:
  private let urlSession: URLSession
  private let logger: Logger
  private let fileService: FileService

  private var apiKey: String {
    // FIXME: Test that this is safe to force unwrap
    // swiftlint:disable:next force_cast
    return NSDictionary(contentsOfFile: self.path)!.value(forKey: "DarkSkyKey") as! String
  }

  init(urlSession: URLSession, logger: Logger, fileService: FileService) {
    self.urlSession = urlSession
    self.logger = logger
    self.fileService = fileService
  }

  /// Make a get request at the url passed in
  /// - warning: Data or Error is not returned on the main thread
  private func makeGetRequest(urlAddition: String, onSuccess: DataCallback?, onError: ErrorCallback?) {
    // swiftlint:disable:next force_unwrapping
    let url = URL(string: "\(baseURL)\(urlAddition)")!
    let request = URLRequest(url: url)

    let task = self.urlSession.dataTask(with: request) { data, _, error in
      if let err = error {
        onError?(err)
        return
      }

      guard let data = data else {
        onError?(Errors.NetworkError.noData)
        return
      }
      onSuccess?(data)
    }
    task.resume()
  }

  /// Get the forecast data for a given location
  /// - warning: 0 timestamp means to get the weather for the current time
  func getForecastFor(location: CLLocation, timestamp: Int = 0) {
    // FIXME: Should we just inject the current UNIX timestamp instead of 0?

    let lat = location.coordinate.latitude
    let long = location.coordinate.longitude

    self.logger.logDebug("Getting forecast for latitude: \(lat) & longitude: \(long)")
    let urlAddition = timestamp > 0 ? "\(apiKey)/\(lat),\(long),\(timestamp)" : "\(apiKey)/\(lat),\(long)"

    self.makeGetRequest(urlAddition: urlAddition, onSuccess: { [weak self] data in
      do {
        self?.logger.logJson(data)
        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        self?.delegate?.apiClientGotForecast(forecast)
      } catch let err {
        self?.logger.logError(err)
        self?.delegate?.apiClientGotError(err)
      }
    }, onError: { [weak self] error in
      self?.delegate?.apiClientGotError(error)
    })
  }
}
