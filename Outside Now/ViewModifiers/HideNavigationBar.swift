//
//  HideNavigationBar.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/16/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation
import SwiftUI

struct HideNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}
