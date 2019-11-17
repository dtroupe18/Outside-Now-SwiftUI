//
//  ResignKeyboardOnDragGesture.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/16/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation
import SwiftUI

struct ResignKeyboardOnDragGesture: ViewModifier {
  var gesture = DragGesture().onChanged { _ in
    UIApplication.shared.endEditing(true)
  }
  
  func body(content: Content) -> some View {
    content.gesture(gesture)
  }
}
