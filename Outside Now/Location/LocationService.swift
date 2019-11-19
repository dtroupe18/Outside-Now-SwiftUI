//
//  LocationService.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreLocation
import UIKit

protocol LocationServiceDelegate {
  func locationSet(to location: CLLocation)
  func locationStringSet(to locationStr: String)
}

final class LocationService: NSObject {
  var delegate: LocationServiceDelegate?

  private let locationManager = CLLocationManager()
  private let geoCoder = CLGeocoder()

  private(set) var currentLocation: CLLocation? {
    didSet {
      if let location = currentLocation {
        delegate?.locationSet(to: location)
      }
    }
  }

  private(set) var locationString: String? {
    didSet {
      if let locationStr = locationString {
        delegate?.locationStringSet(to: locationStr)
        print("Location string updated to \(locationStr)")
      }
    }
  }

  private var authStatus = CLLocationManager.authorizationStatus()

  public var canAccessLocation: Bool {
    switch authStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      return true
    case .denied, .restricted, .notDetermined:
      return false
    @unknown default:
      // FIXME: Log This
      return false
    }
  }

  public var locationAccessDenied: Bool {
    return authStatus == .denied
  }

  override init() {
    super.init()
    locationManager.delegate = self

    if CLLocationManager.locationServicesEnabled() {
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.startUpdatingLocation()
    }
  }

  public func requestAccess() {
    if authStatus == .denied {
      // FIXME: We cannot ask the user again so we just want to alert them
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  private func setPlaceMark(location: CLLocation) {
    self.geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
      if let err = error {
        // FIXME
        print("ERROR: \(String(describing: self)) \(#line) \(err.localizedDescription)")
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
        self.locationString =  "\(city), \(country)"
        return
      }

      self.locationString =  city
      return
    }

    if let state = state {
      if let country = country {
        self.locationString =  "\(state), \(country)"
        return
      }

      self.locationString =  state
      return
    }

    // Stranger Things Easter Egg
    self.locationString =  "Hawkins, IN"
  }

  func searchForPlacemark(text: String, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
    geoCoder.geocodeAddressString(text, completionHandler: { (placemarks, error) in
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
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    self.authStatus = status
    if status == .denied {
      // FIXME:
      // We cannot ask the user again so we just want to alert them
    } else if status == .authorizedAlways || status == .authorizedWhenInUse {
      self.locationManager.startUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let lastLocation = locations.last {
      manager.stopUpdatingLocation()
      manager.delegate = nil // FIXME: Does this need to be reset when searching?
      self.currentLocation = lastLocation
      self.setPlaceMark(location: lastLocation)
    }
  }
}
