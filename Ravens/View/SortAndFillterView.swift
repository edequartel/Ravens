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
  
  var intValue: Int? {
    switch self {
    case .date: return 0   // Represents no filtering
    case .rarity: return 1
    case .name: return 2
    case .scientificName: return 3
    }
  }
  
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
  
  /// Returns the corresponding integer value for each rarity level
  var intValue: Int? {
    switch self {
    case .all: return 0   // Represents no filtering
    case .common: return 1
    case .uncommon: return 2
    case .rare: return 3
    case .veryRare: return 4
    }
  }
  
  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}

enum FilterAllOption: String, CaseIterable {
  case all
  case native
  
  /// Returns the corresponding integer value for each rarity level
  var intValue: Int? {
    switch self {
    case .all: return 0 // Represents no filtering
    case .native: return 1
    }
  }
  
  // Add more filter options if needed
  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}

struct FilteringAllOptionsView: View {
  @Binding var currentFilteringAllOption: FilterAllOption
  
  var body: some View {
    if showView { Text("FilteringAllOptionsView").font(.customTiny) }
    List(FilterAllOption.allCases, id: \.self) { option in
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
}

//==========================================================================================
struct ObservationRowView: View {
  let index: Int?
  var obs: Observation
  @Binding var selectedSpeciesID: Int?
  
  var entity: EntityType
  
  var body: some View {
    VStack {
      if showView { Text("ObservationRowView").font(.customTiny) }
      NavigationLink(destination: ObsDetailView(obs: obs, selectedSpeciesID: $selectedSpeciesID,  entity: entity)) {
        ObsView(
          index: index,
          selectedSpeciesID: $selectedSpeciesID,
          entity: entity,
          obs: obs
        )
        .padding(4)
      }
      Divider()
    }
    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)) // Remove default padding
    .listRowSeparator(.hidden)  // Remove separator line
  }
}

// swiftlint:disable multiple_closures_with_trailing_closure
struct FilterOptionsView: View {
  @Binding var currentFilteringOption: FilteringRarityOption
  
  var body: some View {
    if showView { Text("FilterOptionsView").font(.customTiny) }
    List(FilteringRarityOption.allCases, id: \.self) { option in
      Button(action: {
        currentFilteringOption = option
      }) {
        HStack {
          Image(systemName: "circle.fill")
            .foregroundColor(rarityColor(value: option.intValue ?? 0))
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

// swiftlint:enable multiple_closures_with_trailing_closure
struct ObservationToolbarModifier: ViewModifier {
  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?

  var entity: EntityType

  init(
    currentSortingOption: Binding<SortingOption?> = .constant(nil),
    currentFilteringAllOption: Binding<FilterAllOption?> = .constant(nil),
    currentFilteringOption: Binding<FilteringRarityOption?> = .constant(nil),
    timePeriod: Binding<TimePeriod?> = .constant(nil),
    entity: EntityType = .user // ✅ Added entity as a parameter with a default

  ) {
    self._currentSortingOption = currentSortingOption
    self._currentFilteringAllOption = currentFilteringAllOption
    self._currentFilteringOption = currentFilteringOption
    self._timePeriod = timePeriod
    self.entity = entity
  }
  
  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(
            destination: CombinedOptionsMenuView(
              currentSortingOption: $currentSortingOption,
              currentFilteringAllOption: $currentFilteringAllOption,
              currentFilteringOption: $currentFilteringOption,
              timePeriod: $timePeriod,
              entity: entity
            )
          ) {
            Image(systemName: "ellipsis.circle")
              .uniformSize()
              .accessibilityLabel(sortAndFilterObservationList)
          }
        }
      }
  }
}

struct CombinedOptionsMenuView: View {
  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?

  @EnvironmentObject var settings: Settings

  var entity: EntityType

  var body: some View {
    NavigationStack{
      Form {
        // Period Filter
        if timePeriod != nil {
          Section(header: Text(period)) {
            PeriodView(timePeriod: $timePeriod, entity: entity)
          }
        }
        
        if entity == .radius {
          Section(distance) {
            RadiusPickerView(selectedRadius: $settings.radius)
          }
        }
        
        // Sorting Option
        if currentSortingOption != nil {
          Section(header: Text(sort)) {
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
        }
        
        // Filter All/Native
        if currentFilteringAllOption != nil {
          Section(header: Text(filter)) {
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
        }
        
        // Rarity Filter
        if currentFilteringOption != nil {
          Section(header: Text(rarity)) {
            ForEach(FilteringRarityOption.allCases, id: \.self) { option in
              Button(action: {
                currentFilteringOption = option
              }) {
                HStack {
                  Image(systemName: "circle.fill")
                    .foregroundColor(rarityColor(value: option.intValue ?? 0))
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
  }
}


struct PeriodView: View {
  @Binding var timePeriod: TimePeriod?
  var entity: EntityType

  var body: some View {
    Picker(timePeriodlabel, selection: $timePeriod) {
      ForEach(filteredTimePeriods, id: \.self) { period in
        Text(period.localized).tag(period)
      }
    }
    .pickerStyle(.menu)
  }

  /// Filters `TimePeriod.allCases` based on entity
  private var filteredTimePeriods: [TimePeriod] {
    entity == .radius ? Array(TimePeriod.allCases.prefix(3)) : TimePeriod.allCases
  }
}

