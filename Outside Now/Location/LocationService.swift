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
  func locationSet()
}

final class LocationService: NSObject {
  var delegate: LocationServiceDelegate?

  private let locationManager = CLLocationManager()
  private let geoCoder = CLGeocoder()

  public var currentLocation: CLLocation? {
    didSet {
      if currentLocation != nil {
        print("Current location \(String(describing: currentLocation))")
        delegate?.locationSet()
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

  public func getPlaceMark(completion: @escaping(_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
      if let location = locationManager.location {
        // self.currentLocation = location
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
          if let err = error {
            completion(nil, err)
          }
          if let places = placemarks {
            let placemarkArray = places as [CLPlacemark]
            if !placemarkArray.isEmpty {
              completion(placemarkArray[0], nil)
            }
          }
        }
      }
      else if let location = self.currentLocation {
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
          if let err = error {
            completion(nil, err)
          }
          if let places = placemarks {
            let placemarkArray = places as [CLPlacemark]
            if !placemarkArray.isEmpty {
              completion(placemarkArray[0], nil)
            }
          }
        }
      }
      else if let location = CLLocationManager().location {
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
          if let err = error {
            completion(nil, err)
          }
          if let places = placemarks {
            let placemarkArray = places as [CLPlacemark]
            if !placemarkArray.isEmpty {
              completion(placemarkArray[0], nil)
            }
          }
        }
      }
  }

//  func parsePlacemark(placemark: CLPlacemark) {
//      guard let location = placemark.location else { return }
//      // Update lastPlacemark everytime a new one is parsed
//      //
//      self.lastPlacemark = placemark
//      getWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//      setLocationLabel(placemark: placemark)
//  }
//
//  func setLocationLabel(placemark: CLPlacemark) {
//      let city = placemark.locality
//      let state = placemark.administrativeArea
//      let country = placemark.country
//
//      if city != nil && state != nil {
//          locationLabel.text = "\(city!), \(state!)"
//      } else if city != nil && country != nil {
//          locationLabel.text = "\(city!), \(country!)"
//      } else if state != nil && country != nil {
//          locationLabel.text = "\(state!), \(country!)"
//      } else if city != nil {
//          locationLabel.text = "\(city!)"
//      } else if state != nil {
//          locationLabel.text = "\(state!)"
//      } else if country != nil {
//          locationLabel.text = "\(country!)"
//      } else {
//          // Stranger Things Easter Egg
//          //
//          locationLabel.text = "Hawkins, IN"
//      }
//  }

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
      self.currentLocation = lastLocation

      // let x = lastLocation.coordinate.latitude
    }
  }
}
