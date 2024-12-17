//
//  ObservationUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import SwiftyBeaver

struct CustomDivider: View {
    var color: Color = .gray
    var width: CGFloat = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: width)
    }
}


struct ObservationsUserView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

    @State private var currentSortingOption: SortingOption = .date
    @State private var currentFilteringAllOption: FilterAllOption = .native
    @State private var currentFilteringOption: FilteringRarityOption = .all

  var body: some View {
    VStack {
      if showView { Text("ObservationsUserView").font(.customTiny) }
//      Text("nr: \(observationUser.count)")
      if let observations = observationUser.observations, !observations.isEmpty {
        HorizontalLine()
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          timePeriod: $settings.timePeriodUser,
          entity: .user
        ) {
            // Handle end of list event
            observationUser.fetchData(
              settings: settings,
              url: observationUser.next,
              completion: { log.error("observationUser.fetchData")
              })
          }
      } else {
        NoObservationsView()
      }
    }

    .onAppear {
      if !settings.hasUserLoaded {
        observationUser.fetchDataInit(
          settings: settings,
          entity: .user,
          id: settings.userId,
          completion: {
            log.info("observationsUser.fetchData completion \(observationUser.observations?.count ?? 0)")
            log.info("prv: \(observationUser.previous)")
            log.info("nxt: \(observationUser.next)")
          })
        settings.hasUserLoaded = true
      }
    }
    .refreshable {
      log.error("refreshing observation user")
      observationUser.fetchDataInit(
        settings: settings,
        entity: .user,
        id: settings.userId,
        completion: {
          log.info("observationsUser.fetchData completion \(observationUser.observations?.count ?? 0)")
          log.info("prv: \(observationUser.previous)")
          log.info("nxt: \(observationUser.next)")
        })
    }
  }
}

//struct ObservationsUserView_Previews: PreviewProvider {
//  @State static var selectedObservation: Observation? = nil
//  @State static var selectedObservationSound: Observation? = nil
//
//  static var previews: some View {
//    ObservationsUserView(selectedSpeciesID: .constant(nil))
//    .environmentObject(ObservationsViewModel())
//    .environmentObject(UserViewModel())
//    .environmentObject(Settings())
//  }
//}

