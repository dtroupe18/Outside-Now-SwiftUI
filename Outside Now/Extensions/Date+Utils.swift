//
//  Date+Utils.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

extension Date {
  var millisecondsSinceEpoch: Int64 {
    return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }
}
