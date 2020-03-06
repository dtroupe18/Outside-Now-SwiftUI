//
//  Logger.swift
//  Outside Now
//
//  Created by Dave Troupe on 3/6/20.
//  Copyright © 2020 High Tree Development. All rights reserved.
//

import CocoaLumberjack
import Crashlytics
import DeviceKit
import Foundation

protocol LogCollector: AnyObject {
  func retrieveLogs() -> [String]
}

final class Logger: LogCollector {
  private let fileLogger: DDFileLogger = {
    let logger = DDFileLogger() // File Logger
    logger.rollingFrequency = 60 * 60 * 24 // 24 hours
    logger.logFileManager.maximumNumberOfLogFiles = 7
    return logger
  }()

  init() {
    DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.debug) // Uses os_log
    DDLog.add(self.fileLogger, with: DDLogLevel.debug)
  }

  public func logError(
    _ error: Error,
    additionalInfo: [String: Any]? = nil,
    filename: String = #file,
    line: Int = #line,
    column: Int = #column,
    funcName: String = #function
  ) {
    DDLogError("🚨 ERROR: \(self.sourceFileName(filePath: filename))] line: \(line) \(funcName) -> \(error.localizedDescription)")

    var fullUserInfo = additionalInfo ?? [:]
    fullUserInfo["file"] = filename
    fullUserInfo["line"] = line
    fullUserInfo["column"] = column
    fullUserInfo["function"] = funcName
    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: fullUserInfo)
  }

  public func logDebug(
    _ object: Any,
    filename: String = #file,
    line: Int = #line,
    column _: Int = #column,
    funcName: String = #function
  ) {
    DDLogDebug("🕵: \(self.sourceFileName(filePath: filename))] line: \(line) \(funcName) -> \(object)")
  }

  public func logJson(_ data: Data, msg: String? = nil) {
    let json = data.asJsonString

    if let message = msg {
      if Device.current.isSimulator {
        // use print because only so much data will be logged
        print("\(message)\n\(json)")
      } else {
        DDLogDebug("\(message)\n\(json)")
      }
    } else {
      if Device.current.isSimulator {
        print(json)
      } else {
        DDLogDebug(json)
      }
    }
  }

  private func sourceFileName(filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    return components.last ?? ""
  }

  public func retrieveLogs() -> [String] {
    let logFilePaths = self.fileLogger.logFileManager.sortedLogFilePaths
    var logs: [String] = []

    for logFilePath in logFilePaths {
      let fileURL = NSURL(fileURLWithPath: logFilePath)
      if let logFileData = try? NSData(contentsOf: fileURL as URL, options: NSData.ReadingOptions.mappedIfSafe),
        let logLine = String(data: logFileData as Data, encoding: .utf8) {
        // Write a line so we can clearly see that a new file is starting
        logs.append("\n\n\nStarting new log file \(logFilePath)\n\n\n")
        logs += logLine.components(separatedBy: "\n")
      }
    }

    return logs
  }
}
