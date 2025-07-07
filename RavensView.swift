//
//  RavensView.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/11/2024.
//

import SwiftUI
import SwiftyBeaver

struct RavensView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var observationUser: ObservationsViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel

  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var observationsSpecies: ObservationsViewModel
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  //  @EnvironmentObject var settings: Settings
  @State private var selectedSpeciesID: Int?

  //  @EnvironmentObject var notificationsManager: NotificationsManager

  var body: some View {
    if  !keyChainViewModel.token.isEmpty {
      TabView {
        // Tab 1

        TabUserObservationsView(selectedSpeciesID: $selectedSpeciesID)
          .tabItem {
            Text(usName)
            Image(systemSymbol: .person2Fill)
          }

        // Tab 2
        TabRadiusView(observationsRadiusViewModel: observationsRadiusViewModel,
                      selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text(radius)
          Image(systemSymbol: .circle)
        }

        // Tab 3
        TabLocationView(
          observationsLocation: observationsLocation,
          selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text(location)
          Image(systemSymbol: SFAreaFill)
        }

        // Tab 3
        TabSpeciesView(
          observationsSpecies: observationsSpecies,
          selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text(species)
          Image(systemSymbol: .tree)
        }

        // Tab ??
//        FavoObservationListView()
//          .tabItem {
//            Text("Favorite")
//            Image(systemSymbol: .circlebadge)
//          }
        
        // Tab 4
        SettingsView()
          .tabItem {
            Text(settingsName)
            Image(systemSymbol: .gearshape)
          }

        RingtoneMakerView()
          .tabItem {
            Text("ringtone")
            Image(systemSymbol: .musicNote)
          }

      }
      .sheet(item: $selectedSpeciesID) { item in
        SpeciesDetailsView(speciesID: item)
      }
      .onAppear {
        log.error("*** NEW LAUNCHING RAVENS ***")
      }
    } else {
      TabView {
        // Tab 1
        TabRadiusView(observationsRadiusViewModel: observationsRadiusViewModel,
                      selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Radius")
          Image(systemSymbol: .circle)

        }
        // Tab 4
        SettingsView()
          .tabItem {
            Text(settingsName)
            Image(systemSymbol: .gearshape)
          }
      }
      .sheet(item: $selectedSpeciesID) { item in
        SpeciesDetailsView(speciesID: item)
      }
      .onAppear {
        log.error("*** NEW LAUNCHING RAVENS ***")
      }

    }
  }
}
