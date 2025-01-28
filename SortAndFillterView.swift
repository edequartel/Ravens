//
//  SortAndFillter.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/12/2024.
//

import SwiftUI


enum SortingOption: String, CaseIterable {
  case date
  case rarity
  case name
  case scientificName

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
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

struct ObservationRowView: View {
  var obs: Observation
  @Binding var selectedSpeciesID: Int?

  var entity: EntityType

  var body: some View {
    VStack {
      if showView { Text("ObservationRowView").font(.customTiny) }
      NavigationLink(destination: ObsDetailView(obs: obs, selectedSpeciesID: $selectedSpeciesID)) {
        ObsView(
          entity: entity,
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
//    .navigationTitle("Filtering")
  }
}


struct CombinedOptionsMenuView: View {
  @Binding var currentSortingOption: SortingOption
  @Binding var currentFilteringAllOption: FilterAllOption
  @Binding var currentFilteringOption: FilteringRarityOption

  @Binding var timePeriod: TimePeriod

  var body: some View {
    Form {
      Section(period) {
        VStack {
          PeriodView(timePeriod: $timePeriod)
        }
      }

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

