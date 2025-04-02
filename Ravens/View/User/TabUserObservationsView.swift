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
  @EnvironmentObject var observationUser : ObservationsViewModel
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var obsObserversViewModel: ObserversViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var userViewModel:  UserViewModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel

  @State private var showFirstView = false
  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all
  @State private var timePeriod: TimePeriod? = .fourWeeks

  @Binding var selectedSpeciesID: Int?

  @State private var refresh: Bool = false
  @State private var firstTime: Bool = true

  var body: some View {
    NavigationStack{
      VStack {
        if showView { Text("TabUserObservationsView").font(.customTiny) }

        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsUserView(
            observationUser: observationUser,

            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption

          )
        } else {
          ObservationsUserView(
            observationUser: observationUser,
            selectedSpeciesID: $selectedSpeciesID,

            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption,

            setRefresh: $refresh)
        }
      }

      .onChange(of: userViewModel.loginSuccess) { newValue, oldValue in
        log.info("update userViewModel.loginSuccess")
        obsObserversViewModel.observerId = userViewModel.user?.id ?? 0
        obsObserversViewModel.observerName = userViewModel.user?.name ?? ""
      }

      .onChange(of: timePeriod) {
        log.error("update timePeriodUser")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          timePeriod: timePeriod ?? .fourWeeks,
          completion: { log.error("fetch data complete") } )
      }

      .onChange(of: refresh) {
        log.info("update refresh")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          timePeriod: timePeriod ?? .fourWeeks,
          completion: { log.info("fetch data complete") } )
      }

      .onChange(of: obsObserversViewModel.observerId) {
        log.info("update obsObserversViewModel.observerId")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          timePeriod: timePeriod ?? .fourWeeks,
          completion: { log.info("fetch data complete") } )
      } 

      //sort filter and periodTime
      .modifier(
          ObservationToolbarModifier(
            currentSortingOption: $currentSortingOption,
            currentFilteringOption: $currentFilteringOption,
            timePeriod: $timePeriod)
      )


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
                observerId: $obsObserversViewModel.observerId,
                observerName: $obsObserversViewModel.observerName)
            ) {
              Image(systemSymbol: .listBullet)
                .uniformSize()
                .accessibility(label: Text(observersList))
            }
          }

          //add choose observers
          if (obsObserversViewModel.observerId != (userViewModel.user?.id ?? 0)) {
            ToolbarItem(placement: .navigationBarTrailing) {
              ObserversXXXButtonView(
                userId: obsObserversViewModel.observerId,
                userName: obsObserversViewModel.observerName
              )
            }
          }

        }


      }
      .onAppear {
        if firstTime {
          log.info("Onappear first time")
          firstTime = false
          showFirstView = settings.mapPreference
          // Run loadUserData asynchronously
                  Task {
                      await loadUserData()
                  }

        }
      }
    }
  }

  func imageForUser(userId: Int) -> String {
    return isUserInRecords(userId: userId) ? "star.fill" : "star"
  }

  func isUserInRecords(userId: Int) -> Bool {
    return obsObserversViewModel.isObserverInRecords(userID: userId)
  }

  private func loadUserData() async {
    observationUser.fetchDataInit(
      settings: settings,
      entity: .user,
      token: keyChainViewModel.token,
      id: obsObserversViewModel.observerId,
      timePeriod: timePeriod ?? .fourWeeks,
      completion: {
        log.info("fetch loadUserData observationUser.fetchDataInit complete")
        userViewModel.fetchUserData(settings: settings, token: keyChainViewModel.token) {
          log.info("userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
          obsObserversViewModel.observerName = userViewModel.user?.name ?? ""
          obsObserversViewModel.observerId = userViewModel.user?.id ?? 0
        }
      }
    )
  }
}

