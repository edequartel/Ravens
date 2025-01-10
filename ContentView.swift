//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct ContentView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationUser : ObservationsViewModel
  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var observationsSpecies: ObservationsViewModel

  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @State private var dataLoaded = false

  var body: some View {
    Group {
      if keyChainviewModel.token.isEmpty { //oops when it is not empty CHRIS
        // Login View
        Text("LOGIN")
        LoginView()
          .onAppear {
            log.error("No token, displaying login")
          }
      }
      else { //token is not empty and is okay
        if dataLoaded {
          RavensView(
            observationUser: observationUser,
            observationsLocation: observationsLocation,
            observationsSpecies: observationsSpecies)
          .onAppear {
            log.info("RavensView, Data loaded, navigating to main content")
          }
        } else {
          SplashView(dataLoaded: $dataLoaded)
            .onAppear {
              log.error("SplashView appeared, checking if data is loaded")
              if dataLoaded {
                log.error("Data already loaded")
              } else {
                log.error("Data not loaded yet, triggering load process")
              }
//              log.error("SplashView: Loading data")
//              guard let location = locationManagerModel.location else {
//                log.error("Location not available yet")
//                return
//              }
//
//              log.info("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }
      }
    }
    .onAppear() {
      log.error(keyChainviewModel.loginName)
      log.error(keyChainviewModel.password)
      log.error(keyChainviewModel.token)
    }
  }
}


