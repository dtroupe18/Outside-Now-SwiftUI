//
//  LocationCurrentWeatherView.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import SwiftUI

struct LocationCurrentWeatherView: View {
  
  var body: some View {
    VStack(alignment: .center) {
      Text("East Brunswick, NJ")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("41°")
        .font(.title)
        .fontWeight(.light)

      Text("Daily Summary")
        .fontWeight(.bold)

      Text("Overcast throughout the day.")
        .fontWeight(.light)

      HighLowSummaryView()
    }
  }
}

#if DEBUG
struct LocationCurrentWeatherView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LocationCurrentWeatherView()
        .environment(\.colorScheme, .light)

      //      LocationCurrentWeatherView()
      //        .environment(\.colorScheme, .dark)
    }
  }
}
#endif
