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

//    // Example method to provide a description for each case
//    var description: String {
//        switch self {
//        case .area:
//            return "Area"
//        case .user:
//            return "User"
//        case .species:
//            return "Species"
//        }
//    }
//
//    // Example method for icon names for each case (optional)
//    var iconName: String {
//        switch self {
//        case .area:
//            return "map"
//        case .user:
//            return "person"
//        case .species:
//            return "leaf"
//        }
//    }
}

struct ObservationsView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var observationsViewModel: ObservationsViewModel
  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var settings: Settings

//  @Binding var selectedObservation: Observation?

  var body: some View {
    VStack {
      if showView { Text("ObservationsView").font(.customTiny) }
      if let results = observationsViewModel.observations?.results, results.count > 0 {
        HorizontalLine()
        List {
          if let results =  observationsViewModel.observations?.results {
            ForEach(results, id: \.id) { obs in
              VStack {
                NavigationLink(destination: ObsDetailView(obs: obs)) {
                  ObsView(
                    showSpecies: true, showObserver: false, showArea: true,
//                    selectedObservation: $selectedObservation,
                    obs: obs
                  )
                  .padding(8)
                }

                .accessibilityLabel("\(obs.species_detail.name) \(obs.date) \(obs.time ?? "")")
                Divider()
              }
              .listRowInsets(EdgeInsets())
              .listRowSeparator(.hidden)

            }
          }
        }
        .listStyle(PlainListStyle())

        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: ObserversView()) {
              Label("Observers", systemImage: "list.bullet")
            }
          }

          if (!settings.accessibility) {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(action: {
                settings.hidePictures.toggle()
              }) {
                ImageWithOverlay(systemName: "photo", value: !settings.hidePictures)
              }
            }
          }
        }
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
    ObservationsView()
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
