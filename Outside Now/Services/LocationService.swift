//
//  LocationService.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreLocation
import UIKit

protocol LocationServiceDelegate: AnyObject {
  func locationPermissionDenied()
  func locationUpdated(to location: CLLocation)
}

final class LocationService: NSObject {
  private let logger: Logger
  weak var delegate: LocationServiceDelegate?

  private let locationManager = CLLocationManager()
  private let geoCoder = CLGeocoder()

  private(set) var currentLocation: CLLocation? {
    didSet {
      if let location = currentLocation {
        self.delegate?.locationUpdated(to: location)
      }
    }
  }

  private(set) var locationString: String? {
    didSet {
      if let locationStr = locationString {
        self.logger.logDebug("Location string updated to \(locationStr)")
      }
    }
  }

  private var authStatus = CLLocationManager.authorizationStatus()

  public var canAccessLocation: Bool {
    switch self.authStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      return true
    case .denied, .restricted, .notDetermined:
      return false
    @unknown default:
      let err = NSError(
        domain: "",
        code: 4001,
        userInfo: [NSLocalizedDescriptionKey: "unknown case returned for CLLocationManager.authorizationStatus \(authStatus)"]
      )
      logger.logError(err)
      return false
    }
  }

  public var locationAccessDenied: Bool {
    return self.authStatus == .denied
  }

  init(logger: Logger) {
    self.logger = logger
    super.init()

    self.locationManager.delegate = self

    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      self.locationManager.startUpdatingLocation()
    }
  }

  public func requestAccess() {
    if self.authStatus == .denied {
      self.delegate?.locationPermissionDenied()
    } else {
      self.locationManager.requestWhenInUseAuthorization()
    }
  }

  private func setPlaceMark(location: CLLocation) {
    self.geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
      if let err = error {
        self?.logger.logError(err)
        return
      }

      if let places = placemarks, let first = places.first {
        self?.setLocationStringFrom(placemark: first)
      }
    }
  }

  private func setLocationStringFrom(placemark: CLPlacemark) {
    let city = placemark.locality
    let state = placemark.administrativeArea
    let country = placemark.country

    if let city = city {
      if let state = state {
        self.locationString = "\(city), \(state)"
        return
      }

      if let country = country {
        self.locationString = "\(city), \(country)"
        return
      }

      self.locationString = city
      return
    }

    if let state = state {
      if let country = country {
        self.locationString = "\(state), \(country)"
        return
      }

      self.locationString = state
      return
    }

    // Stranger Things Easter Egg
    self.locationString = "Hawkins, IN"
  }

  func searchForPlacemark(text: String, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> Void) {
    self.geoCoder.geocodeAddressString(text, completionHandler: { placemarks, error in
      if let err = error {
        completion(nil, err)
      }
      if let places = placemarks {
        let placemarkArray = places as [CLPlacemark]
        if !placemarkArray.isEmpty {
          completion(placemarkArray[0], nil)
        }
      }
    })
  }
}

extension LocationService: CLLocationManagerDelegate {
  func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    self.authStatus = status
    if status == .denied {
      self.delegate?.locationPermissionDenied()
    } else if status == .authorizedAlways || status == .authorizedWhenInUse {
      self.locationManager.startUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let lastLocation = locations.last {
      manager.stopUpdatingLocation()
      manager.delegate = nil
      self.currentLocation = lastLocation
      self.setPlaceMark(location: lastLocation)
    }
  }
}
