//
//  ProfileView.swift
//  Outside Now
//
//  Created by Dave Troupe on 11/17/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading){
        HStack{
          Text("username")
            .foregroundColor(.blue)
            .fontWeight(.semibold)
            .padding(.leading, 10)

          Button(action: {}){
            Image("arrow-down")
              .resizable()
              .frame(width: 10, height: 10)
          }
          .padding(.top, 5)

          Spacer()

          Button(action: {}){
            Image("menu")
              .resizable()
              .frame(width: 20, height: 20)
          }.padding()
        }
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}
