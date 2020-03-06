//
//  Copy.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

// swiftlint:disable line_length
enum Copy: CustomStringConvertible {
  case locationAccessDeniedTitle
  case locationAccessDeniedMsg

  var description: String {
    switch self {
    case .locationAccessDeniedTitle:
      return "Location Access Denied"
    case .locationAccessDeniedMsg:
      return "Without access to your location Outside Now can only provide weather if your search for a location. You can update location access in settings."
    }
  }
}
