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

            Menu {
              CombinedOptionsMenuView(
                currentSortingOption: $currentSortingOption,
                currentFilteringOption: $currentFilteringOption )
            } label: {
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                }
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
      let dateFormatter = DateFormatter()
      let timeFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      timeFormatter.dateFormat = "HH:mm"

      switch currentSortingOption {
      case .date:
          let lhsDate = dateFormatter.date(from: lhs.date) ?? Date.distantPast
          let rhsDate = dateFormatter.date(from: rhs.date) ?? Date.distantPast

          if lhsDate != rhsDate {
              return lhsDate > rhsDate
          } else {
              let lhsTime = timeFormatter.date(from: lhs.time ?? "") ?? Date.distantPast
              let rhsTime = timeFormatter.date(from: rhs.time ?? "") ?? Date.distantPast
              return lhsTime < rhsTime
          }

      case .name:
          return lhs.species_detail.name < rhs.species_detail.name
      case .rarity:
          return lhs.rarity > rhs.rarity
      case .scientificName:
            return lhs.species_detail.scientific_name < rhs.species_detail.scientific_name
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

struct FilteringMenu: View {
    @Binding var currentFilteringOption: FilteringRarityOption

    var body: some View {
        NavigationLink(destination: FilterOptionsView(currentFilteringOption: $currentFilteringOption)) {
            Image(systemName: "line.3.horizontal.decrease")
                .accessibilityElement(children: .combine)
                .accessibility(label: Text("Filtering"))
        }
        .accessibility(label: Text("Menu filter"))
    }
}

struct FilterOptionsView: View {
    @Binding var currentFilteringOption: FilteringRarityOption

    var body: some View {
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
    @Binding var currentFilteringOption: FilteringRarityOption

    var body: some View {
        Menu {
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

            Divider()

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
        } label: {
            Text("Options")
        }
    }
}

struct _SortOptionsMenuView: View {
    @Binding var currentSortingOption: SortingOption

    var body: some View {
        Menu {
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
        } label: {
            Text("Sort Options")
        }
    }
}

struct _FilterOptionsMenuView: View {
    @Binding var currentFilteringOption: FilteringRarityOption

    var body: some View {
        Menu {
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
        } label: {
            Text("Filter Options")
        }
    }
}

//#Preview {
//  @State static var selectedObservation: Observation? = nil
//    ObservationListView(
//      observations: [selectedObservation],
//      entity: .area,
//      selectedSpeciesID: .constant(nil))
//}
