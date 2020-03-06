//
//  Data+Utils.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/19/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

extension Data {
  var asJsonString: String {
    if let dict = try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] {
      return dict.asJsonString
    }

    return "invalid JSON"
  }
}
