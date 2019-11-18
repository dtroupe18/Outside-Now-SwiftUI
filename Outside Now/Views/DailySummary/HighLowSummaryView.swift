//
//  HighLowSummaryView.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import SwiftUI

struct HighLowSummaryView: View {
  var body: some View {
    HStack {
      HStack {
        Text("High")
          .fontWeight(.bold)
          .padding(.leading, 8)
        Text("42°")
          .fontWeight(.light)
      }

      Spacer()
      HStack {
        Text("Low")
          .fontWeight(.bold)
        Text("36°")
          .fontWeight(.light)
          .padding(.trailing, 8)
      }
    }
  }
}

#if DEBUG
struct HighLowSummaryView_Previews: PreviewProvider {
  static var previews: some View {
    HighLowSummaryView()
  }
}
#endif
