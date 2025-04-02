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
  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @EnvironmentObject var observersViewModel: ObserversViewModel

  @Binding var selectedSpeciesID: Int?
  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?

  @Binding var setRefresh: Bool

  var body: some View {
    VStack {
      if showView { Text("ObservationsUserView").font(.customTiny) }

      HStack {
//        if observersViewModel.isObserverInRecords(userID: observersViewModel.observerId) {
//          Image(systemSymbol: SFObserverFill)
//        }
        Text("\(observersViewModel.observerName)")
          .bold()
          .lineLimit(1)
          .truncationMode(.tail)
        Spacer()
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .accessibilityLabel(observersViewModel.observerName)

      if let observations = observationUser.observations, !observations.isEmpty {
        HorizontalLine()
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          timePeriod: $settings.timePeriodUser,
          entity: .user,
          currentSortingOption: $currentSortingOption,
          currentFilteringAllOption: $currentFilteringAllOption,
          currentFilteringOption: $currentFilteringOption
        ) {
            // Handle end of list event
            observationUser.fetchData(
              settings: settings,
              url: observationUser.next,
              token: keyChainviewModel.token,
              completion: { log.error("END OF LIST -->> observationUser.fetchData")
              })
          }
      } else {
        NoObservationsView()
      }

    }
    .onAppear {
      log.info("onappear observation user")
    }
    .refreshable {
      log.info("refresh onappear observation user")
      setRefresh.toggle()
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

