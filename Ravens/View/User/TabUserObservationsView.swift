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

  @EnvironmentObject var userViewModel:  UserViewModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel

  @State private var showFirstView = false

  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringAllOption: FilterAllOption = .native
  @State private var currentFilteringOption: FilteringRarityOption = .all

  @Binding var selectedSpeciesID: Int?

  @State private var observerId: Int = 0
  @State private var observerName: String = ""

  @State private var refresh: Bool = false

  var body: some View {
    NavigationView {
      VStack {
//        Button("Refresh") {refresh.toggle()}
//        Text("id \(userViewModel.user?.id ?? 0)")
//        Text("name \(userViewModel.user?.name ?? "noName")")
//        Text("setObserver \(observerId)")
//        Text("setObserverString \(observerName)")

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
            setRefresh: $refresh)
        }
      }

      .onChange(of: userViewModel.loginSuccess) {
        log.error("update userViewModel.loginSuccess")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: userViewModel.user?.id ?? 0,
          completion: { log.info("fetch data complete")
            observerId =  userViewModel.user?.id ?? 0
            observerName = userViewModel.user?.name ?? ""} )
      }

      .onChange(of: settings.timePeriodUser) {
        log.error("update timePeriodUser")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: userViewModel.user?.id ?? 0,
          completion: { log.info("fetch data complete") } )
      }

      .onChange(of: observerName) {
        log.error("update setObserver")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: observerId,
          completion: { log.info("fetch data complete") } )
      }

      .onChange(of: refresh) {
        log.error("update refresh")

        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          token: keyChainviewModel.token,
          id: observerId,
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
                observerId: $observerId,
                observerName: $observerName)
            ) {
              Image(systemSymbol: .listBullet)
                .uniformSize()
                .accessibility(label: Text(observersList))
            }
          }
        }
      }

      .navigationTitle("\(observerName)")
      .navigationBarTitleDisplayMode(.inline)


      .onAppearOnce {
        log.error("ONAPPEAROnce TABUSERS")
        observerId = userViewModel.user?.id ?? 0
        observerName = userViewModel.user?.name ?? ""

        showFirstView = settings.mapPreference
      }
//      .onAppear {
//        log.error("ONAPPEAR TABUSERS")
//      }
    }
  }

  func imageForUser(userId: Int) -> String {
    return isUserInRecords(userId: userId) ? "star.fill" : "star"
  }

  func isUserInRecords(userId: Int) -> Bool {
    return obsObserversViewModel.isObserverInRecords(userID: userId)
  }
}


