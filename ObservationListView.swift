//
//  ObservationListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/09/2024.
//

import SwiftUI

enum SortingOption {
    case date
    case name
    case rarity
}

enum FilteringOption {
    case all
    case common
    case uncommon
    case rare
    case veryRare
}

struct ObservationListView: View {
  var observations: [Observation]
  var entity: EntityType
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringOption: FilteringOption = .all

  var body: some View {
    List {
      ForEach(observations
                  .filter(meetsCondition)
                  .sorted(by: compareObservations), id: \.id) { obs in
        VStack {
          NavigationLink(destination: ObsDetailView(obs: obs)) {
            ObsView(
              showSpecies: !(entity == .species),  //<--
              showObserver: !(entity == .user),
              showArea: !(entity == .area),
              selectedSpeciesID: $selectedSpeciesID,
              obs: obs
            )
            .padding(8)
          }
          .accessibilityLabel("\(obs.species_detail.name) \(obs.date) \(obs.time ?? "")")
          Divider()
        }
        .listRowInsets(EdgeInsets(top:0, leading:16, bottom:0, trailing:16)) // Remove default padding
        .listRowSeparator(.hidden)  // Remove separator line
      }
    }
    .listStyle(PlainListStyle()) // No additional styling, plain list look
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        SortingMenu(currentSortingOption: $currentSortingOption)
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        FilteringMenu(currentFilteringOption: $currentFilteringOption)
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
      }
  }
//  func compareObservations(lhs: Observation, rhs: Observation) -> Bool {
//      let dateFormatter = DateFormatter()
//      let timeFormatter = DateFormatter()
//      dateFormatter.dateFormat = "yyyy-MM-dd"
//      timeFormatter.dateFormat = "HH:mm"
//
//
//      switch currentSortingOption {
//      case .date:
//
//          let lhsDateTimeString = "\(lhs.date) \(lhs.time ?? "")"
//          let rhsDateTimeString = "\(rhs.date) \(rhs.time ?? "")"
//
//          let lhsDateTime = dateFormatter.date(from: lhsDateTimeString) ?? Date.distantPast
//          let rhsDateTime = dateFormatter.date(from: rhsDateTimeString) ?? Date.distantPast
//
//          return lhsDateTime < rhsDateTime
//
//      case .name:
//          return lhs.species_detail.name < rhs.species_detail.name
//      case .rarity:
//          return lhs.rarity > rhs.rarity
//      }
//  }
}



struct FilteringMenu: View {
    @Binding var currentFilteringOption: FilteringOption

    var body: some View {
        Menu {
          Picker(selection: $currentFilteringOption, label: Text("Filtering")) {
            Text("All").tag(FilteringOption.all)
            Text("Common").tag(FilteringOption.common)
            Text("Uncommon").tag(FilteringOption.uncommon)
            Text("Rare").tag(FilteringOption.rare)
            Text("Very rare").tag(FilteringOption.veryRare)
          }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .accessibilityElement(children: .combine)
                .accessibility(label: Text("Filtering"))
        }
    }
}


struct SortingMenu: View {
    @Binding var currentSortingOption: SortingOption

    var body: some View {
        Menu {
            Picker(selection: $currentSortingOption, label: Text("Sorting")) {
                Text("Date").tag(SortingOption.date)
                Text("Rarity").tag(SortingOption.rarity)
                Text("Name").tag(SortingOption.name)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .accessibilityElement(children: .combine)
                .accessibility(label: Text("Sorting"))
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
