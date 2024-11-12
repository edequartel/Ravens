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
  @EnvironmentObject var settings: Settings
  @State private var selectedSpeciesID: Int?

  @EnvironmentObject var notificationsManager: NotificationsManager

  var body: some View {
    VStack {
      TabView {
        // Tab 2
        TabUserObservationsView(selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Us")
          Image(systemSymbol: .person2Fill)
        }
        // Tab 1
        TabLocationView(selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Area")
          Image(systemSymbol: SFAreaFill)
        }
        // Tab 3
        TabSpeciesView(
          selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Species")
          Image(systemSymbol: .tree)
        }
        // Tab 4
        SettingsView()
          .tabItem {
            Text("Settings")
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
