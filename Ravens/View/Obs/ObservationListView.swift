//
//  ObservationListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/09/2024.
//

import SwiftUI
import AudioToolbox
import SwiftyBeaver

struct ObservationListView: View {
  let log = SwiftyBeaver.self
  
  var observations: [Observation]

  @EnvironmentObject var settings: Settings
  @Binding var selectedSpeciesID: Int?
  @Binding var timePeriod: TimePeriod

  var entity: EntityType

  @Binding var currentSortingOption: SortingOption? // = .date
  @Binding var currentFilteringAllOption: FilterAllOption? //= .native
  @Binding var currentFilteringOption: FilteringRarityOption? //= .all

  @AccessibilityFocusState private var focusedItemID: Int?

  /// Closure to notify parent view that the end of the list is reached
  var onEndOfList: (() -> Void)?

  var body: some View {
    List {
      let filteredAndSortedObservations = observations
          .filter(meetsCondition)
          .sorted(by: compareObservations)

      ForEach(filteredAndSortedObservations,
                 id: \.id) { obs in
             ObservationRowView(
              obs: obs,
              selectedSpeciesID: $selectedSpeciesID,
              entity: entity)
                 .accessibilityFocused($focusedItemID, equals: obs.idObs)
                 .onChange(of: focusedItemID) { newFocusID, oldFocusID in
                     handleFocusChange(newFocusID, from: filteredAndSortedObservations)
                 }
                 .onAppear {
                     if obs == filteredAndSortedObservations.last {
                       log.error("end of list reached")
                       onEndOfList?()  // this is closure in observationSpeciesView(..) { closure() }
                     }
                 }
         }
    }
    .listStyle(PlainListStyle()) // No additional styling, plain list look
  }

  private func handleFocusChange(_ newFocusID: Int?, from observations: [Observation]) {
      guard let newFocusID = newFocusID else { return }
      if let focusedObservation = observations.first(where: { $0.idObs == newFocusID }) {
        print("\(focusedObservation.speciesDetail.name) \(focusedObservation.sounds?.count ?? 0)")
        if focusedObservation.sounds?.count ?? 0 > 0 {
              print("vibrate")
            vibrate()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
          }
      }
  }

  func meetsCondition(observation: Observation) -> Bool {
    switch currentFilteringOption {
    case .all:
      return true
    case .common:
      return observation.rarity == 1
    case .uncommon:
      return observation.rarity == 2
    case .rare:
      return observation.rarity == 3
    case .veryRare:
      return observation.rarity == 4
    case .none:
      return true
    }
  }

  func compareObservations(lhs: Observation, rhs: Observation) -> Bool {
    switch currentSortingOption {
    case .date:
      return (lhs.timeDate ?? Date.distantPast) > (rhs.timeDate ?? Date.distantPast) 
    case .name:
      return lhs.speciesDetail.name < rhs.speciesDetail.name
    case .rarity:
      return lhs.rarity > rhs.rarity
    case .scientificName:
      return lhs.speciesDetail.scientificName < rhs.speciesDetail.scientificName
    case .none:
      return false
    }
  }
}


