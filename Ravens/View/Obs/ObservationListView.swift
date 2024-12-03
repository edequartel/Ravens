//
//  ObservationListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/09/2024.
//

import SwiftUI
import AudioToolbox

struct ObservationListView: View {
  var observations: [Observation]
  @EnvironmentObject var settings: Settings
  @Binding var selectedSpeciesID: Int?
  @State var entity: EntityType //@@@
  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringAllOption: FilterAllOption = .native
  @State private var currentFilteringOption: FilteringRarityOption = .all
  @AccessibilityFocusState private var focusedItemID: Int?

  var body: some View {

    List {
      // Precompute the filtered and sorted list
      let filteredAndSortedObservations = observations
          .filter(meetsCondition)
          .sorted(by: compareObservations)

      ForEach(filteredAndSortedObservations,
              id: \.id) { obs in
          ObservationRowView(obs: obs, selectedSpeciesID: $selectedSpeciesID, entity: entity)
          .accessibilityFocused($focusedItemID, equals: obs.id)
          .onChange(of: focusedItemID) { newFocusID, oldFocusID in
              handleFocusChange(newFocusID, from: filteredAndSortedObservations)
          }
//          .onChange(of: focusedItemID) { newFocusID in
//              handleFocusChange(newFocusID, from: filteredAndSortedObservations)
//          }
        }
    }

    .listStyle(PlainListStyle()) // No additional styling, plain list look
    .modifier(ObservationToolbarModifier(
                   entity: entity,
                   currentSortingOption: $currentSortingOption,
                   currentFilteringAllOption: $currentFilteringAllOption,
                   currentFilteringOption: $currentFilteringOption
               ))

  }

  private func handleFocusChange(_ newFocusID: Int?, from observations: [Observation]) {
      guard let newFocusID = newFocusID else { return }
      if let focusedObservation = observations.first(where: { $0.id == newFocusID }) {
        print("\(focusedObservation.speciesDetail.name) \(focusedObservation.sounds?.count ?? 0)")
        if focusedObservation.sounds?.count ?? 0 > 0 {
              print("vibrate")
            vibrate()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//            AudioServicesPlaySystemSound(1057)
          }
      }
  }

  //@@@
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
    }
  }

  func compareObservations(lhs: Observation, rhs: Observation) -> Bool {
    switch currentSortingOption {
    case .date:
      return (lhs.timeDate ?? Date.distantPast) > (rhs.timeDate ?? Date.distantPast) //@@@
    case .name:
      return lhs.speciesDetail.name < rhs.speciesDetail.name
    case .rarity:
      return lhs.rarity > rhs.rarity
    case .scientificName:
      return lhs.speciesDetail.scientificName < rhs.speciesDetail.scientificName
    }
  }
}

struct ObservationToolbarModifier: ViewModifier {
    var entity: EntityType
    @Binding var currentSortingOption: SortingOption
    @Binding var currentFilteringAllOption: FilterAllOption
    @Binding var currentFilteringOption: FilteringRarityOption

    func body(content: Content) -> some View {
        content
            .toolbar {
                if entity != .species {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(
                            destination: CombinedOptionsMenuView(
                                currentSortingOption: $currentSortingOption,
                                currentFilteringAllOption: $currentFilteringAllOption,
                                currentFilteringOption: $currentFilteringOption
                            )
                        ) {
                            Image(systemName: "ellipsis.circle")
                            .uniformSize(color: .red)
                            .accessibilityLabel(sortAndFilterObservationList)
                        }
                    }
                }
            }
    }
}

struct ObservationRowView: View {
  var obs: Observation
  @Binding var selectedSpeciesID: Int?
  var entity: EntityType

  var body: some View {
    VStack {
      if showView { Text("ObservationRowView").font(.customTiny) }
      NavigationLink(destination: ObsDetailView(obs: obs, selectedSpeciesID: $selectedSpeciesID)) {
        ObsView(
          showSpecies: !(entity == .species),
          showObserver: !(entity == .user),
          showArea: !(entity == .area),
          selectedSpeciesID: $selectedSpeciesID,
          obs: obs
        )
        .padding(4)
      }
      Divider()
    }
    .listRowInsets(EdgeInsets(top:0, leading:16, bottom:0, trailing:16)) // Remove default padding
    .listRowSeparator(.hidden)  // Remove separator line
  }
}

enum FilteringRarityOption: String, CaseIterable {
  case all
  case common
  case uncommon
  case rare
  case veryRare

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}


struct FilterOptionsView: View {
  @Binding var currentFilteringOption: FilteringRarityOption

  var body: some View {
    if showView { Text("FilterOptionsView").font(.customTiny) }
    List(FilteringRarityOption.allCases, id: \.self) { option in
      Button(action: {
        currentFilteringOption = option
      }) {
        HStack {
          Text(option.localized)
          Spacer()
          if currentFilteringOption == option {
            Image(systemName: "checkmark")
          }
        }
      }
    }
    .navigationTitle("Filtering")
  }
}

//enum @@@
enum SortingOption: String, CaseIterable {
  case date
  case rarity
  case name
  case scientificName

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}

struct CombinedOptionsMenuView: View {
  @Binding var currentSortingOption: SortingOption
  @Binding var currentFilteringAllOption: FilterAllOption
  @Binding var currentFilteringOption: FilteringRarityOption

  var body: some View {
    Form {
      Section(sort) {
        ForEach(SortingOption.allCases, id: \.self) { option in
          Button(action: {
            currentSortingOption = option
          }) {
            HStack {
              Text(option.localized)
              Spacer()
              if currentSortingOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
      //      Divider()
      Section(status) {
        ForEach(FilterAllOption.allCases, id: \.self) { option in
          Button(action: {
            currentFilteringAllOption = option
          }) {
            HStack {
              Text(option.localized)
              Spacer()
              if currentFilteringAllOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
      
      //      Divider()
      Section(rarity) {
        ForEach(FilteringRarityOption.allCases, id: \.self) { option in
          Button(action: {
            currentFilteringOption = option
          }) {
            HStack {
              Text(option.localized)
              Spacer()
              if currentFilteringOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
    }
  }
}

