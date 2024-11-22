//
//  ObservationListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/09/2024.
//

import SwiftUI

struct ObservationListView: View {
  var observations: [Observation]

  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  @State var entity: EntityType
  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringAllOption: FilterAllOption = .native
  @State private var currentFilteringOption: FilteringRarityOption = .all

  var body: some View {

    List {
      ForEach(observations
        .filter(meetsCondition)
        .sorted(by: compareObservations), id: \.id) { obs in
          ObservationRowView(obs: obs, selectedSpeciesID: $selectedSpeciesID, entity: entity)
        }
    }
    .listStyle(PlainListStyle()) // No additional styling, plain list look
    .toolbar {
      if entity != .species {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: CombinedOptionsMenuView(
            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption )) {
              Image(systemSymbol: .ellipsisCircle)
                .uniformSize(color: .red)
              .accessibility(label: Text("Sort en filter"))
          }
        }
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
  case all = "All"
  case common = "Common"
  case uncommon = "Uncommon"
  case rare = "Rare"
  case veryRare = "Very rare"
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
          Text(option.rawValue)
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

//enum
enum SortingOption: String, CaseIterable {
  case date = "Date"
  case rarity = "Rarity"
  case name = "Name"
  case scientificName = "Scientific Name"
}

struct CombinedOptionsMenuView: View {
  @Binding var currentSortingOption: SortingOption
  @Binding var currentFilteringAllOption: FilterAllOption
  @Binding var currentFilteringOption: FilteringRarityOption

  var body: some View {
    Form {
      Section("Sort") {
        ForEach(SortingOption.allCases, id: \.self) { option in
          Button(action: {
            currentSortingOption = option
          }) {
            HStack {
              Text(option.rawValue)
              Spacer()
              if currentSortingOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
      //      Divider()
      Section("Native") {
        ForEach(FilterAllOption.allCases, id: \.self) { option in
          Button(action: {
            currentFilteringAllOption = option
          }) {
            HStack {
              Text(option.rawValue)
              Spacer()
              if currentFilteringAllOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
      
      //      Divider()
      Section("Rarity") {
        ForEach(FilteringRarityOption.allCases, id: \.self) { option in
          Button(action: {
            currentFilteringOption = option
          }) {
            HStack {
              Text(option.rawValue)
              Spacer()
              if currentFilteringOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
    }
//    Spacer()
  }
}
