//
//  Errors.swift
//  Outside Now
//
//  Created by Dave Troupe on 3/6/20.
//  Copyright © 2020 High Tree Development. All rights reserved.
//

import Foundation

/**
 All Errors used in Outside Now.
 */
enum Errors: Swift.Error {
  enum NetworkError: Swift.Error {
    case noData
    case decodeFailed

    var localizedDescription: String {
      switch self {
      case .decodeFailed:
        return "The server response is missing data. Please try again."
      case .noData:
        return "No response from server please try again."
      }
    }
  }
}
