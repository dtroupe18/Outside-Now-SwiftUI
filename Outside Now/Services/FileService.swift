//
//  FileService.swift
//  Outside Now
//
//  Created by Dave Troupe on 3/6/20.
//  Copyright © 2020 High Tree Development. All rights reserved.
//

import Foundation

/**
 This service is used and returns optionals so that we
 can test that these files exist and that force unwrapped them
 throughout the app is "safe".
 */
struct FileService {
  private enum FileExt: String {
    case plist
  }

  private enum FileName: String {
    case keys = "Keys"
  }

  var keysPlistPath: String? {
    Bundle.main.path(
      forResource: FileService.FileName.keys.rawValue,
      ofType: FileService.FileExt.plist.rawValue
    )
  }

  var keysPlist: NSDictionary? {
    guard let path = self.keysPlistPath else { return nil }
    return NSDictionary(contentsOfFile: path)
  }

  var darkSkyApiKey: String? {
    keysPlist?.value(forKey: "DarkSkyKey") as? String
  }
}
