//
//  UserObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import SwiftyBeaver

struct TabUserObservationsView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var obsObserversViewModel: ObserversViewModel

  @EnvironmentObject private var userViewModel:  UserViewModel


  @State private var showFirstView = false

  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringAllOption: FilterAllOption = .native
  @State private var currentFilteringOption: FilteringRarityOption = .all

  @Binding var selectedSpeciesID: Int?

  @State private var setObserver: Int = 0
  @State private var setRefresh: Bool = false

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
            selectedSpeciesID: $selectedSpeciesID,
            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption,
            setRefresh: $setRefresh)
        }
      }
      
      .onChange(of: settings.timePeriodUser) {
        log.error("update timePeriodUser so new data fetch for this period")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
//          id: userViewModel.user?.id ?? 0,
          id: setObserver,
          completion: { log.info("fetch data complete") } )
      }

      
      .onChange(of: setObserver) {
        log.error("update setObserver so new data fetch for this period")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          id: setObserver,
          completion: { log.info("fetch data complete") } )
      }

      .onChange(of: setRefresh) {
        log.error("update setRefresh so new data fetch for this period")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          id: setObserver,
          completion: { log.info("fetch data complete") } )
      }

      //sort filter and periodTime
      .modifier(ObservationToolbarModifier(
        currentSortingOption: $currentSortingOption,
        currentFilteringAllOption: $currentFilteringAllOption,
        currentFilteringOption: $currentFilteringOption,
        timePeriod: $settings.timePeriodUser
      ))

      .toolbar {
        //set map or list
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


          //add choose observers
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(
              destination: ObserversView(
                observationUser: observationUser,
                setObserver: $setObserver)
            ) {
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
        setObserver =  userViewModel.user?.id ?? 0 //??? may be use published all the time userViewModel.user?.id instead of setObserver
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


