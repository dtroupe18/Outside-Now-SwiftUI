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

protocol ApiClientDelegate: class {
  func apiClientGotError(_ error: Error)
  func apiClientGotForecast(_ forecast: Forecast)
}

final class ApiClient {
  weak var delegate: ApiClientDelegate?

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

  func getForecastFor(location: CLLocation, timestamp: Int?) {
    let lat = location.coordinate.latitude
    let long = location.coordinate.longitude

    let urlAddition = timestamp == nil ? "\(apiKey)/\(lat),\(long)" : "\(apiKey)/\(lat),\(long),\(timestamp!)"

    self.makeGetRequest(urlAddition: urlAddition, onSuccess: { data in
      do {
        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        print("Forecast \(forecast)")
        self.delegate?.apiClientGotForecast(forecast)
      } catch {
        // FIXME: Log this error
        self.delegate?.apiClientGotError(RequestError.decodeFailed.error)
      }
    }, onError: { error in
      self.delegate?.apiClientGotError(error)
    })
  }
}
