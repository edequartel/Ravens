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

  @EnvironmentObject var userViewModel:  UserViewModel

  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @State private var dataLoaded = false

  @State private var setObserver: Int = 0


  var body: some View {
    Group {
      if !keyChainviewModel.token.isEmpty {
//      if !userViewModel.loginSuccess || keyChainviewModel.token.isEmpty {
//      if !userViewModel.loginSuccess {
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
        }
      }
    }
//    .onAppear() { //?? how does this works
//      if !keyChainviewModel.token.isEmpty {
//        userViewModel.loginSuccess = true
//      }
//      log.error(keyChainviewModel.token)
//    }
  }
}


