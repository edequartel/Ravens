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
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var keyChainviewModel: KeychainViewModel
    @State private var dataLoaded = false

    var body: some View {
        Group {
            if keyChainviewModel.token.isEmpty {
                // Login View
                LoginView()
                    .onAppear {
                        log.info("No token, displaying login")
                    }
            } else {
                if dataLoaded {
                    RavensView()
                        .onAppear {
                            log.info("Data loaded, navigating to main content")
                        }
                } else {
                    SplashView(dataLoaded: $dataLoaded)
                        .onAppear {
                            log.info("Loading data in SplashView")
                            if let location = locationManagerModel.location {
                                log.error("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                            } else {
                                log.error("Location not available yet")
                            }
                        }
                }
            }
        }
    }
}


//struct ContentView: View {
//    let log = SwiftyBeaver.self
//    @EnvironmentObject var locationManagerModel: LocationManagerModel
//    @EnvironmentObject var keyChainviewModel: KeychainViewModel
//
//    @State private var dataLoaded = false
//
//    var body: some View {
//        Group {
//            if keyChainviewModel.token.isEmpty {
//                // Show login screen if the token is missing
//                VStack {
//                    HStack {
//                        Text("Login waarneming.nl")
//                            .bold()
//                            .font(.title)
//                            .padding()
//                        Spacer()
//                    }
//                    LoginView()
//                }
//                .onAppear {
////                    CLLocationManager().requestWhenInUseAuthorization()
//                    log.error("Token is empty, showing login screen")
//                }
//            } else {
//                if dataLoaded {
//                    // Show the main content if data is loaded
//                    RavensView()
//                        .onAppear {
//                            log.error("Data loaded, navigating to main content")
//                        }
//                } else {
//                    // Show splash view to load data
//                    SplashView(dataLoaded: $dataLoaded)
//                        .onAppear {
//                            log.error("Loading data via SplashView")
//                        }
//                }
//            }
//        }
//    }
//}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(Settings())
  }
}

