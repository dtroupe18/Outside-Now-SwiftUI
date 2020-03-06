//
//  WeatherDataStructs.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import UIKit

// MARK: - Forcast

struct Forecast: Codable {
  let minutely: Minutely
  let currently: Currently
  let latitude: Double
  let offset: Int
  let longitude: Double
  let flags: Flags
  let daily: Daily
  let timezone: String
  let hourly: Hourly
  let alerts: [Alert]?
}

// MARK: - Alert

struct Alert: Codable {
  let title: String
  let time, expires: Int
  let alertDescription: String
  let uri: String

  enum CodingKeys: String, CodingKey {
    case title, time, expires
    case alertDescription = "description"
    case uri
  }
}

// MARK: - Currently

struct Currently: Codable {
  let apparentTemperature, pressure, precipIntensity: Double
  let time: Int
  let windSpeed, windGust: Double
  let summary: String
  let temperature: Double
  let uvIndex: Int
  let icon: IconName
  let nearestStormDistance: Int?
  let visibility, humidity, dewPoint: Double
  let precipType: PrecipType?
  let windBearing: Int
  let cloudCover, ozone, precipProbability: Double
  let precipIntensityError: Double?

  /// Returns double as string with MPH appended
  var windSpeedString: String? {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 0

    let speed = self.windSpeed.rounded(.toNearestOrAwayFromZero)

    let formatedString = formatter.string(from: NSNumber(value: speed))
    if var string = formatedString {
      string += " MPH"
      return string
    } else {
      return nil
    }
  }

  func hourString(timeZone: TimeZone?) -> String {
    return self.time.asDouble.hourString(timeZone: timeZone)
  }
}

// MARK: - ICON NAME

enum IconName: String, Codable {
  // FIXME: Get SF image
  case clearDay = "clear-day"
  case clearNight = "clear-night"
  case rain
  case snow
  case sleet
  case wind
  case fog
  case cloudy
  case partlyCloudyDay = "partly-cloudy-day"
  case partlyCloudyNight = "partly-cloudy-night"

  // FIXME: Check this
  // Future:
  // case hail
  // case thunderstorm
  // case tornado

  // SF Symbols
  var image: UIImage? {
    switch self {
    case .clearDay:
      return UIImage(systemName: "sun.max.fill")
    case .clearNight:
      return UIImage(systemName: "moon.stars.fill")
    case .rain:
      return UIImage(systemName: "cloud.rain.fill")
    case .snow:
      return UIImage(systemName: "cloud.snow.fill")
    case .sleet:
      return UIImage(systemName: "cloud.sleet.fill")
    case .wind:
      return UIImage(systemName: "wind")
    case .fog:
      return UIImage(systemName: "cloud.fog.fill")
    case .cloudy:
      return UIImage(systemName: "cloud.fill")
    case .partlyCloudyDay:
      return UIImage(systemName: "cloud.sun.fill")
    case .partlyCloudyNight:
      return UIImage(systemName: "cloud.moon.fill")
    }
  }
}

enum PrecipType: String, Codable {
  case rain
  case snow
  case sleet
}

// MARK: - Daily

struct Daily: Codable {
  let summary: String
  let icon: IconName
  let data: [DailyData]
}

// MARK: - DailyData

struct DailyData: Codable {
  let icon: IconName
  let windGustTime, temperatureLowTime: Int
  let dewPoint: Double
  let summary: String
  let temperatureMax, humidity, windGust, precipIntensityMax: Double
  let cloudCover, ozone: Double
  let apparentTemperatureMinTime, precipIntensityMaxTime, sunriseTime: Int
  let precipIntensity, windSpeed: Double
  let apparentTemperatureHighTime: Int
  let apparentTemperatureMin, apparentTemperatureHigh: Double
  let apparentTemperatureLowTime: Int
  let precipProbability: Double
  let temperatureHighTime: Int
  let pressure: Double
  let sunsetTime, windBearing, temperatureMinTime: Int
  let temperatureLow, temperatureHigh: Double
  let uvIndexTime: Int
  let apparentTemperatureMax: Double
  let apparentTemperatureMaxTime: Int
  let visibility, moonPhase, apparentTemperatureLow: Double
  let time: Int
  let precipType: PrecipType?
  let uvIndex: Int
  let temperatureMin: Double
  let temperatureMaxTime: Int

  func sunriseHourMinStr(timeZone: TimeZone?) -> String {
    return self.sunriseTime.asDouble.hourMinString(timeZone: timeZone)
  }

  func sunsetHourMinStr(timeZone: TimeZone?) -> String {
    return self.sunsetTime.asDouble.hourMinString(timeZone: timeZone)
  }

  func timeString(includeDayName: Bool) -> String {
    return self.time.asDouble.monthDayString(includeDayName: includeDayName)
  }

  var dayName: String {
    return self.time.asDouble.dayNameString()
  }
}

// MARK: - Flags

struct Flags: Codable {
  let sources: [String]
  let units: String
  let nearestStation: Double

  enum CodingKeys: String, CodingKey {
    case sources, units
    case nearestStation = "nearest-station"
  }
}

// MARK: - Hourly

struct Hourly: Codable {
  let summary: String
  let icon: IconName
  let data: [Currently]
}

// MARK: - Minutely

struct Minutely: Codable {
  let summary: String
  let icon: IconName
  let data: [MinutelyData]
}

// MARK: - MinutelyData

struct MinutelyData: Codable {
  let precipIntensityError: Double?
  let precipType: PrecipType?
  let precipIntensity: Double
  let time: Int
  let precipProbability: Double
}
