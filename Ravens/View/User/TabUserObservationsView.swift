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

  @EnvironmentObject var observationUser: ObservationsViewModel
  var allObservationNamesText1: String {
    let rows = (observationUser.observations ?? [])
      .compactMap {
        return "\($0.speciesDetail.name) \($0.number)x"
      }
      .joined(separator: "\n")
    return "\(rows)"
  }

  var allObservationNamesText: String {
    let rows = (observationUser.observations ?? [])
      .map {
        let name = $0.speciesDetail.name.padding(toLength: 12, withPad: " ", startingAt: 0)
        let number = "\($0.number)x"
        return "\(name) \(number)"
      }
      .joined(separator: "\n")
    return "\(rows)"
  }

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var obsObserversViewModel: ObserversViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel

  @EnvironmentObject var speciesViewModel: SpeciesViewModel

  @State private var showFirstView = false
  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all

  @Binding var selectedSpeciesID: Int?

  @State private var refresh: Bool = false
  @State private var firstTime: Bool = true

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("TabUserObservationsView").font(.customTiny) }

        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsUserView(
            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption
          )
        } else {
          ObservationsUserView(
            selectedSpeciesID: $selectedSpeciesID,
            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption,
            setRefresh: $refresh)
        }
      }
      
      .onChange(of: userViewModel.loginSuccess) { newValue, oldValue in
        log.error("update userViewModel.loginSuccess")
        obsObserversViewModel.observerId = userViewModel.user?.id ?? 0
        obsObserversViewModel.observerName = userViewModel.user?.name ?? ""
      }

      .onChange(of: settings.selectedLanguage) {
        log.error("update selectedLanguage \(settings.selectedUserSpeciesGroup ?? 1)")
        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          speciesGroup: settings.selectedUserSpeciesGroup ?? 1,
          timePeriod: settings.timePeriodUser,
          completion: { log.error("fetch data selectedLanguage complete") })
      }

      .onChange(of: settings.selectedUserSpeciesGroup) {
        log.error("update selectedUserSpeciesGroup \(settings.selectedUserSpeciesGroup ?? 1)")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          speciesGroup: settings.selectedUserSpeciesGroup ?? 1,
          timePeriod: settings.timePeriodUser,
          completion: { log.error("fetch data complete") })
      }

      .onChange(of: settings.timePeriodUser) {
        log.error("update timePeriodUser")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          speciesGroup: settings.selectedUserSpeciesGroup ?? 1,
          timePeriod: settings.timePeriodUser,
          completion: { log.error("fetch data complete") })
      }

      .onChange(of: refresh) {
        log.error("update refresh")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          speciesGroup: settings.selectedUserSpeciesGroup ?? 1,
          timePeriod: settings.timePeriodUser,
          completion: { log.info("fetch data complete") })
      }

      .onChange(of: obsObserversViewModel.observerId) {
        log.info("update obsObserversViewModel.observerId")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: obsObserversViewModel.observerId,
          speciesGroup: settings.selectedUserSpeciesGroup ?? 1,
          timePeriod: settings.timePeriodUser,
          completion: { log.info("fetch data complete") })
      }

      // sort filter and periodTime
      .modifier( 
        ObservationToolbarModifier(
          currentSortingOption: $currentSortingOption,
          currentFilteringOption: $currentFilteringOption,
          currentSpeciesGroup: $settings.selectedUserSpeciesGroup,
          timePeriod: $settings.timePeriodUser)
//          entity: .user)
      )

      .toolbar {
        // set map or list
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
        }

        // add choose observers
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(
            destination: ObserversView(
              observerId: $obsObserversViewModel.observerId,
              observerName: $obsObserversViewModel.observerName)
          ) {
            Image(systemSymbol: .listBullet)
              .uniformSize()
              .accessibility(label: Text(observersList))
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: FavoObservationListView()
          ) {
            Image(systemSymbol: .bookmark) 
              .uniformSize()
              .accessibility(label: Text(favoObservation))
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          ShareLink(
              item: allObservationNamesText,
              subject: Text(observations)//,
              //preview: SharePreview(observations, image: Image("AppIconShare")) //??
          ) {
              Label(shareObservations, systemSymbol: .squareAndArrowUp)
          }
          .accessibility(label: Text(share))
        }

        // add choose observers
        if obsObserversViewModel.observerId != (userViewModel.user?.id ?? 0) {
          ToolbarItem(placement: .navigationBarTrailing) {
            ObserversButtonView(
              userId: obsObserversViewModel.observerId,
              userName: obsObserversViewModel.observerName
            )
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
    userViewModel.fetchUserData(settings: settings, token: keyChainViewModel.token) {
      log.info("userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
      obsObserversViewModel.observerName = userViewModel.user?.name ?? ""
      obsObserversViewModel.observerId = userViewModel.user?.id ?? 0
    }
  }
}
