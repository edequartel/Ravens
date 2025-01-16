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

  @EnvironmentObject var observationUser : ObservationsViewModel
  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var observationsSpecies: ObservationsViewModel

//  @EnvironmentObject var settings: Settings
  @State private var selectedSpeciesID: Int?

  @EnvironmentObject var notificationsManager: NotificationsManager

  var body: some View {
    VStack {
      TabView {
        // Tab 2
        TabUserObservationsView(
          selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text(us)
          Image(systemSymbol: .person2Fill)
        }
        // Tab 1
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
        // Tab 4
        SettingsView()
          .tabItem {
            Text(settings_)
            Image(systemSymbol: .gearshape)
          }
      }

      .sheet(item: $selectedSpeciesID) { item in
        SpeciesDetailsView(speciesID: item)
      }
      .onAppear() {
        log.error("*** NEW LAUNCHING RAVENS ***")
      }
    }
  }
}
