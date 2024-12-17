//
//  UserObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct TabUserObservationsView: View {
  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var obsObserversViewModel: ObserversViewModel

  @State private var showFirstView = false

//  @State var Xentity: EntityType
  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringAllOption: FilterAllOption = .native
  @State private var currentFilteringOption: FilteringRarityOption = .all
//  @State private var timePeriod: TimePeriod = .fourWeeks

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    NavigationView {
      VStack {
        if showView { Text("TabUserObservationsView").font(.customTiny) }

        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsUserView(
            observationUser: observationUser)
        } else {
          ObservationsUserView(
            observationUser: observationUser,
            selectedSpeciesID: $selectedSpeciesID)
        }
      }

      .modifier(ObservationToolbarModifierExtended(
                     currentSortingOption: $currentSortingOption,
                     currentFilteringAllOption: $currentFilteringAllOption,
                     currentFilteringOption: $currentFilteringOption,
                     timePeriod: $settings.timePeriodUser
                 ))

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
            NavigationLink(destination: ObserversView(observationUser: observationUser)) {
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


