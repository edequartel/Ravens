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

enum EntityType: String {
    case area = "locations"
    case user = "user"
    case species = "species"
}

struct ObservationsUserView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    VStack {
      if showView { Text("ObservationsUserView").font(.customTiny) }
      Text("\(observationUser.count) \(observationUser.offset)")
      if let observations = observationUser.observations, !observations.isEmpty {
        HorizontalLine()
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          entity: .user) {
          // Handle end of list event
            print("End of list reached in ParentView observationUser")
            observationUser.fetchData(
              settings: settings,
              entity: .user,
              id: settings.userId,
              completion: { log.info("observationUser.fetchdata \( settings.userId)") }
            )
        }
      } else {
        NoObservationsView()
      }
    }

    .onAppear {
      if settings.initialUsersLoad {
        observationUser.fetchData(
          settings: settings,
          entity: .user,
          id: settings.userId,
          completion: { log.error("observationsUser.fetchData completion \(observationUser.observations?.count ?? 0)") })
        settings.initialUsersLoad = false
        print("ONAPPEAR")
      }
    }
    .refreshable {
      log.info("refreshing")
      observationUser.fetchData(
        settings: settings,
        entity: .user,
        id: settings.userId,
        completion: { log.info("observationsUserViewModel.fetchdata \( settings.userId)") }
      )
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

