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

struct ObservationRowView: View {
  var obs: Observation
  @Binding var selectedSpeciesID: Int?

  var entity: EntityType

  var body: some View {
    VStack {
      if showView { Text("ObservationRowView").font(.customTiny) }
      NavigationLink(destination: ObsDetailView(obs: obs, selectedSpeciesID: $selectedSpeciesID)) {
        ObsView(
          selectedSpeciesID: $selectedSpeciesID,
          entity: entity,
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


struct ContentXView: View {
  @State private var currentSortingOption: SortingOption? = .rarity
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all
  @State private var timePeriod: TimePeriod? = .fourWeeks

  private var atStart = true

    var body: some View {
        NavigationView {
            VStack {
                Text("Main Content")
              Text("\(currentSortingOption?.intValue ?? 0)")
            }
            .navigationTitle("Observations")
            .modifier(observationToolbarModifier(
              currentSortingOption: $currentSortingOption,
              currentFilteringAllOption: $currentFilteringAllOption,
              currentFilteringOption: $currentFilteringOption,
              timePeriod: $timePeriod))
        }
    }
}


struct observationToolbarModifier: ViewModifier {
  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?

  init(
    currentSortingOption: Binding<SortingOption?> = .constant(nil),
    currentFilteringAllOption: Binding<FilterAllOption?> = .constant(nil),
    currentFilteringOption: Binding<FilteringRarityOption?> = .constant(nil),
    timePeriod: Binding<TimePeriod?> = .constant(nil)
  ) {
    self._currentSortingOption = currentSortingOption;
    self._currentFilteringAllOption = currentFilteringAllOption;
    self._currentFilteringOption = currentFilteringOption;
    self._timePeriod = timePeriod
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
                            timePeriod: $timePeriod

                        )
                    ) {
//                        Image(systemName: "ellipsis.circle")
//                            .foregroundColor(.red)
//                            .accessibilityLabel("Sort and Filter Observations")
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

  var body: some View {
    Form {
      //period
      if timePeriod != nil {
        Section(period) {
          VStack {
            PeriodView(timePeriod: $timePeriod)
          }
        }
      }
      //sort
      if currentSortingOption != nil {
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
      }
      //filter all/native
      if currentFilteringAllOption != nil {
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
      }
      //filter rarity
      if currentFilteringOption != nil {
        Section(rarity) {
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

struct PeriodView: View {
    @Binding var timePeriod: TimePeriod?

    var body: some View {
        HStack {
            Picker(timePeriodlabel, selection: $timePeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.localized).tag(period)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

//======================================================

//struct CombinedOptionsMenuViewXXX: View {
//  @Binding var currentSortingOption: SortingOption
//  @Binding var currentFilteringAllOption: FilterAllOption
//  @Binding var currentFilteringOption: FilteringRarityOption
//  @Binding var timePeriod: TimePeriod
//
//  var body: some View {
//    Form {
////      Section(period) {
////        VStack {
////          PeriodView(timePeriod: $timePeriod)
////        }
////      }
//
//      Section(sort) {
//        ForEach(SortingOption.allCases, id: \.self) { option in
//          Button(action: {
//            currentSortingOption = option
//          }) {
//            HStack {
//              Text(option.localized)
//              Spacer()
//              if currentSortingOption == option {
//                Image(systemName: "checkmark")
//              }
//            }
//          }
//        }
//      }
//      //      Divider()
//      Section(status) {
//        ForEach(FilterAllOption.allCases, id: \.self) { option in
//          Button(action: {
//            currentFilteringAllOption = option
//          }) {
//            HStack {
//              Text(option.localized)
//              Spacer()
//              if currentFilteringAllOption == option {
//                Image(systemName: "checkmark")
//              }
//            }
//          }
//        }
//      }
//
//      //      Divider()
//      Section(rarity) {
//        ForEach(FilteringRarityOption.allCases, id: \.self) { option in
//          Button(action: {
//            currentFilteringOption = option
//          }) {
//            HStack {
//              Text(option.localized)
//              Spacer()
//              if currentFilteringOption == option {
//                Image(systemName: "checkmark")
//              }
//            }
//          }
//        }
//      }
//
//    }
//  }
//}

//struct ObservationToolbarModifierXX: ViewModifier {
//  @Binding var currentSortingOption: SortingOption
//  @Binding var currentFilteringAllOption: FilterAllOption
//  @Binding var currentFilteringOption: FilteringRarityOption
//  @Binding var timePeriod: TimePeriod
//
//  func body(content: Content) -> some View {
//    content
//      .toolbar {
////        if false {
//          ToolbarItem(placement: .navigationBarTrailing) {
//            NavigationLink(
//              destination: CombinedOptionsMenuViewXXX(
//                currentSortingOption: $currentSortingOption,
//                currentFilteringAllOption: $currentFilteringAllOption,
//                currentFilteringOption: $currentFilteringOption,
//                timePeriod: $timePeriod
//              )
//            ) {
//              Image(systemName: "ellipsis.circle")
//                .uniformSize(color: .red)
//                .accessibilityLabel(sortAndFilterObservationList)
//            }
//          }
////        }
//
//      }
//  }
//}
