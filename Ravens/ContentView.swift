//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver
import BackgroundTasks
import UserNotifications

struct ContentView: View {
  let log = SwiftyBeaver.self
  @State private var dataLoaded = false

  @EnvironmentObject var keyChainviewModel: KeychainViewModel

  init() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(.clear)
    appearance.shadowColor = .clear

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }

  var body: some View {
    if (keyChainviewModel.token.isEmpty) {
      VStack {
        HStack{
          Text("Login waarneming.nl")
            .bold()
            .font(.title)
            .padding()
          Spacer()
        }
        LoginView()
      }
      .onAppear() {
        log.error("isEmpty")
      }
    } else {
      if dataLoaded {
        RavensView()
          .onAppear() {
            log.info("dataLoaded")
          }
      } else {
        SplashView(dataLoaded: $dataLoaded)
          .onAppear() {
            log.info("SplashScreen")
          }
      }
    }
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(Settings())
  }
}

