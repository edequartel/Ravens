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
    case area = "area"
    case user = "user"
    case species = "species"
}

struct ObservationsUserView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var observationsViewModel: ObservationsViewModel
  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    VStack {
      if showView { Text("ObservationsUserView").font(.customTiny) }
      if let observations = observationsViewModel.observations?.results, observations.count > 0 {
        HorizontalLine()
        ///yyy
        ObservationListView(observations: observations, selectedSpeciesID: $selectedSpeciesID, entity: .user)
      } else {
        ProgressView()
      }
    }

    .onAppear {
      if settings.initialUsersLoad {
        observationsViewModel.fetchData(
          settings: settings,
          entityType: "user",
          userId: settings.userId,
          completion: { log.info("viewModel.fetchData completion") })
        settings.initialUsersLoad = false
      }
    }
    .refreshable {
      log.info("refreshing")
      observationsViewModel.fetchData(
        settings: settings,
        entityType: "user",
        userId: settings.userId,
        completion: { log.info("observationsUserViewModel.fetchdata \( settings.userId)") }
      )
    }
  }
}

struct ObservationsUserView_Previews: PreviewProvider {
  @State static var selectedObservation: Observation? = nil
  @State static var selectedObservationSound: Observation? = nil

  static var previews: some View {
    ObservationsUserView(selectedSpeciesID: .constant(nil))
    .environmentObject(ObservationsViewModel())
    .environmentObject(UserViewModel())
    .environmentObject(Settings())
  }
}

