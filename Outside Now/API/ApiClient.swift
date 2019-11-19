//
//  ApiClient.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation
import CoreLocation

private enum RequestError: String, Error {
  case noData = "No response from server please try again."
  case decodeFailed = "The server response is missing data. Please try again."

  var error: Error {
    return NSError(domain: "", code: 1001, userInfo: [NSLocalizedDescriptionKey : self.rawValue]) as Error
  }
}

typealias DataCallback = (Data) -> Void
typealias ErrorCallback = (Error) -> Void
typealias ForecastCallback = (Forecast) -> Void

final class ApiClient {
  private let path = Bundle.main.path(forResource: "Keys", ofType: "plist")!
  private let baseURL: String =  "https://api.darksky.net/forecast/"

  private var cachedForecasts: [String: Forecast] = [:] // FIXME
  private let urlSession: URLSession

  private var apiKey: String {
    // FIXME: Test that this is safe to force unwrap
    return NSDictionary(contentsOfFile: path)!.value(forKey: "DarkSkyKey") as! String
  }

  init(urlSession: URLSession = URLSession(configuration: .default)) {
    self.urlSession = urlSession
  }

  /// Make a get request at the url passed in
  /// - warning: Data or Error is not returned on the main thread
  private func makeGetRequest(urlAddition: String, onSuccess: DataCallback?, onError: ErrorCallback?) {
    let url = URL(string: "\(baseURL)\(urlAddition)")!
    let request = URLRequest(url: url)

    let task = urlSession.dataTask(with: request) { (data, response, error) in
      if let err = error {
        onError?(err)
        return
      }

      guard let data = data else {
        onError?(RequestError.noData.error)
        return
      }
      onSuccess?(data)
    }
    task.resume()
  }

  /// Returns Forecast struct or Error on the main thread for given latitude and longitude
  func getForeccastFor(location: CLLocation, onSuccess: ForecastCallback?, onError: ErrorCallback?) {
    let lat = location.coordinate.latitude
    let long = location.coordinate.longitude

    self.makeGetRequest(urlAddition: "\(apiKey)/\(lat),\(long)", onSuccess: { data in
      do {
        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        DispatchQueue.main.async {
          onSuccess?(forecast)
        }
      } catch {
        DispatchQueue.main.async {
          onError?(RequestError.decodeFailed.error)
        }
        // FIXME: Log this error!
      }
    }, onError: { error in
      DispatchQueue.main.async {
        onError?(error)
      }
    })
  }

  // Returns Forecast struct or Error on the main thread for the GPS location at time provided
  func getFutureForecast(lat: Double, long: Double, formattedTime: String, onSuccess: ForecastCallback?, onError: ErrorCallback?) {
    self.makeGetRequest(urlAddition: "\(apiKey)/\(lat),\(long),\(formattedTime)", onSuccess: { data in
      do {
        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        DispatchQueue.main.async {
          onSuccess?(forecast)
        }
      } catch {
        DispatchQueue.main.async {
          onError?(RequestError.decodeFailed.error)
        }
        // FIXME: Log this error!
      }
    }, onError: { error in
      DispatchQueue.main.async {
        onError?(error)
      }
    })
  }
}
