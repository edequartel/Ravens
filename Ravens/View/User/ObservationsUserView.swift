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
//  @Binding var selectedObservation: Observation?

  var body: some View {
    VStack {
      if showView { Text("ObservationsView").font(.customTiny) }
      if let observations = observationsViewModel.observations?.results, observations.count > 0 {
        HorizontalLine()

        ObservationListView(observations: observations, entity: .user, selectedSpeciesID: $selectedSpeciesID)
          .environmentObject(Settings()) // Pass environment object
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

//  .sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } )
        //                            .filter { result in
        //                                // Add your condition here
        //                                // For example, the following line filters `result` to keep only those with a specific `rarity`.
        //                                // You can replace it with your own condition.
        //                                ((!settings.showObsPictures) && (!settings.showObsAudio)) ||
        //                                (
        //                                    (result.has_photo ?? false) && (settings.showObsPictures) ||
        //                                    (result.has_sound ?? false) && (settings.showObsAudio)
        //                                )
        //                            }
