//
//  UserObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct TabUserObservationsView: View {
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var obsObserversViewModel: ObserversViewModel

  @State private var showFirstView = false

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    NavigationView {
      VStack {
        if showView { Text("TabUserObservationsView").font(.customTiny) }
//        Text(noObsLastPeriod) // test localisation
//Text(play)
        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsUserView()
        } else {
          ObservationsUserView(selectedSpeciesID: $selectedSpeciesID)
        }
      }

      .toolbar {
        if !accessibilityManager.isVoiceOverEnabled {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              showFirstView.toggle()
            }) {
              Image(systemSymbol: .rectangle2Swap)
                .uniformSize()
                .accessibility(label: Text(swap))
            }
          }


          //add a toolbaritem here to the list of users
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: ObserversView()) {
              Image(systemSymbol: .listBullet)
                .uniformSize()
                .accessibility(label: Text(observersList))
            }
          }
        }
      }

      .navigationTitle("\(settings.userName)")
      .navigationBarTitleDisplayMode(.inline)
      .onAppearOnce {
        showFirstView = settings.mapPreference
      }
    }
  }

  func imageForUser(userId: Int) -> String {
      return isUserInRecords(userId: userId) ? "star.fill" : "star"
  }

  func isUserInRecords(userId: Int) -> Bool {
      return obsObserversViewModel.isObserverInRecords(userID: userId)
  }
}

struct TabUserObservationsView_Previews: PreviewProvider {
  @StateObject static var observationsUserViewModel = ObservationsViewModel()

  static var previews: some View {
    TabUserObservationsView(selectedSpeciesID: .constant(nil))
      .environmentObject(Settings())
      .environmentObject(observationsUserViewModel)
  }
}
