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

  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var observationsSpecies: ObservationsViewModel
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject  var observationUser : ObservationsViewModel
  @EnvironmentObject var userViewModel:  UserViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel

  @State private var dataLoaded = false
  @State private var setObserver: Int = 0

  var body: some View {
    if dataLoaded {
      RavensView(
        observationsLocation: observationsLocation,
        observationsSpecies: observationsSpecies,
        observationsRadiusViewModel: observationsRadiusViewModel)
      .onAppear {
        log.info("RavensView, Data loaded, navigating to main content")
      }
    } else {
      SplashView(dataLoaded: $dataLoaded)
    }
  }
}


