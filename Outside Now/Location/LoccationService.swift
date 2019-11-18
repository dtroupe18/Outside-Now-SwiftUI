//
//  LoccationService.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import CoreLocation
import UIKit

final class LocationService {

  let locationManager = CLLocationManager()
  let geoCoder = CLGeocoder()
  var currentLocation: CLLocation?
  var authStatus = CLLocationManager.authorizationStatus()

  var canAccessLocation: Bool {
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

  func requestAccess() {
    if authStatus == .denied {
      // We cannot ask the user again so we just want to alert them
      // qwe - return an error?
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  func getPlaceMark(completion: @escaping(_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
    if self.authStatus == .authorizedWhenInUse || self.authStatus == .authorizedAlways {
      if let location = locationManager.location {
        self.currentLocation = location
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
    } else {
      print("Auth status failed... in locationWrapper")
    }
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
