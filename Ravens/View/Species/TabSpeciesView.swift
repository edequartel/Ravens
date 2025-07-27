//
//  SpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct TabSpeciesView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationsSpecies: ObservationsViewModel

  @EnvironmentObject var regionListViewModel: RegionListViewModel

  @EnvironmentObject var speciesViewModel: SpeciesViewModel
  @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
  @EnvironmentObject var accessibilityManager: AccessibilityManager

  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var settings: Settings

  @State private var selectedSortOption: SortNameOption = .name
  @State private var selectedFilterOption: FilterAllOption = .all
  @State private var selectedRarityOption: FilteringRarityOption = .all
  @State private var searchText = ""

  @State private var currentSpeciesGroup: Int? = 1

  @Binding var selectedSpeciesID: Int?

  @State private var showSpeciesXC: Species?

  var body: some View {
    NavigationStack {

      VStack {
        if showView { Text("TabSpeciesView").font(.customTiny) }

        HorizontalLine()

        List {
          ForEach(speciesViewModel.filteredSpecies(
            by: selectedSortOption,
            searchText: searchText,
            filterOption: selectedFilterOption,
            rarityFilterOption: selectedRarityOption,
            isLatest: false,
            isBookmarked: settings.isBookMarkVisible,
            additionalIntArray: bookMarksViewModel
          ), id: \.id) { species in

            NavigationLink(
              destination: SpeciesView(
                observationsSpecies: observationsSpecies,
                item: species,
                selectedSpeciesID: $selectedSpeciesID)
            ) {

              SpeciesInfoView(
                species: species,
                showView: showView)

            }

            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                NavigationLink(destination: SpeciesDetailsView(speciesID: species.speciesId)) {
                  Image(systemSymbol: .infoCircle)
                          .uniformSize()
                  }
                  .tint(.blue)
                  .accessibilityLabel(Text(infoSpecies))
            }

            .swipeActions(edge: .leading, allowsFullSwipe: false) {
              NavigationLink(destination: CreateObservationView(speciesID: species.speciesId, speciesName: species.name)) {
                  Image(systemSymbol: .plusCircle)
                          .uniformSize()
                  }
                  .tint(.red)
            }

            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              BookmarkButtonView(speciesID: species.speciesId)
                .tint(.green)
            }

            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              if [1, 2, 3, 14].contains(settings.selectedSpeciesGroup) {
                NavigationLink(destination: BirdListView(
                  scientificName: species.scientificName,
                  nativeName: species.name)) {
                    Image(systemSymbol: .waveform)
                      .uniformSize()
                  }
                  .tint(.purple)
                  .accessibility(label: Text(audioListView))
              }
            }

          }
        }
        .listStyle(PlainListStyle())
        .searchable(text: $searchText)
      }

      .onChange(of: settings.selectedRegionId) {
        log.error("TabSpeciesView  update settings.selectedRegionId \(settings.selectedRegionId)")
        settings.selectedRegionListId = regionListViewModel.getId(region: settings.selectedRegionId, speciesGroup: settings.selectedSpeciesGroup ?? 1) ?? 5001
        speciesViewModel.fetchDataFirst(settings: settings)
      }

      .onChange(of: settings.selectedSpeciesGroup) {
        print("fetchDataFirst & fetchDataSecondLanguage")
        log.error("TabSpeciesView  update settings.selectedSpeciesGroup \(String(describing: settings.selectedSpeciesGroup))")
        settings.selectedRegionListId = regionListViewModel.getId(region: settings.selectedRegionId, speciesGroup: settings.selectedSpeciesGroup ?? 1) ?? 5001
        speciesViewModel.fetchDataFirst(settings: settings)
        speciesViewModel.fetchDataSecondLanguage(settings: settings) 
      }

      .navigationDestination(item: $showSpeciesXC) { species in
        BirdListView(scientificName: species.scientificName, nativeName: species.name)
      }

      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            settings.isBookMarkVisible.toggle()
          }) {
            Image(systemSymbol: settings.isBookMarkVisible ? .starFill : .star)
              .uniformSize()
          }
          .accessibilityLabel(settings.isBookMarkVisible ? favoriteVisible : allVisible)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: SortFilterSpeciesView(
            selectedSortOption: $selectedSortOption,
            selectedFilterAllOption: $selectedFilterOption,
            selectedRarityOption: $selectedRarityOption
            // currentSpeciesGroup: $settings.selectedSpeciesGroup 
          )) {
            Image(systemSymbol: .ellipsisCircle)
              .uniformSize()
              .accessibility(label: Text(sortAndFilterSpecies))
          }
        }
      }
    }
  }

  var searchResults: [Species] {
    if searchText.isEmpty {
      return speciesViewModel.sortedSpecies(by: selectedSortOption)
    } else {
      return speciesViewModel.sortedSpecies(by: selectedSortOption).filter {
        $0.name.contains(searchText) || $0.scientificName.contains(searchText)
      }
    }
  }

}

struct SortFilterSpeciesView: View {
  @Binding var selectedSortOption: SortNameOption
  @Binding var selectedFilterAllOption: FilterAllOption
  @Binding var selectedRarityOption: FilteringRarityOption
//  @Binding var currentSpeciesGroup: Int?

  @EnvironmentObject var settings: Settings

  var body: some View {

    if showView { Text("SortFilterSpeciesView").font(.customTiny) }

    Form {
      // Selected the SpeciesGroup
      SpeciesGroupPickerView(
        currentSpeciesGroup: $settings.selectedSpeciesGroup,
        entity: .species)

      Section {
        RegionsView()
      }

      // First Menu for Sorting
      Section(sort) {
        SortNameOptionsView(currentFilteringNameOption: $selectedSortOption)
      }

      // Second Menu for Filtering
      Section(status) {
        FilteringAllOptionsView(currentFilteringAllOption: $selectedFilterAllOption)
      }

      Section(rarity) {
        FilterOptionsView(currentFilteringOption: $selectedRarityOption)
      }
    }
  }
}
struct PickTimePeriodeSpeciesView: View {
  @Binding var timePeriod: TimePeriod?

  var body: some View {
    Form {
      Section(period) {
        Picker(timePeriodlabel, selection: $timePeriod) {
          ForEach(TimePeriod.allCases, id: \.self) { period in
            Text(period.localized).tag(period)
          }
        }
        .pickerStyle(.menu)
      }
    }
  }
}

enum SortNameOption: String, CaseIterable {
  case name
  case scientificName

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}

struct SortNameOptionsView: View {
  @Binding var currentFilteringNameOption: SortNameOption

  var body: some View {
    if showView { Text("SortNameOptionsView").font(.customTiny) }

    List(SortNameOption.allCases, id: \.self) { option in
      Button(action: {
        currentFilteringNameOption = option
      }) {
        HStack {
          Text(option.localized)
          Spacer()
          if currentFilteringNameOption == option {
            Image(systemName: "checkmark")
          }
        }
      }
    }
  }
}

struct FilteringAllMenu: View {
  @Binding var currentFilteringAllOption: FilterAllOption

  var body: some View {

    NavigationLink(destination: FilteringAllOptionsView(currentFilteringAllOption: $currentFilteringAllOption)) {
      Image(systemName: "line.3.horizontal.decrease")
        .accessibilityElement(children: .combine)
        .accessibility(label: Text("Filtering"))
    }
    .accessibility(label: Text("Menu filter"))
  }
}

extension SpeciesViewModel {
  func filteredSpecies(
    by sortOption: SortNameOption,
    searchText: String,
    filterOption: FilterAllOption,
    rarityFilterOption: FilteringRarityOption,
    isLatest: Bool,
    isBookmarked: Bool,
    additionalIntArray: BookMarksViewModel
  ) -> [Species] {
    let sortedSpeciesList = sortedSpecies(by: sortOption)

    // Filter by search text if not empty
    var filteredList = searchText.isEmpty ? sortedSpeciesList : sortedSpeciesList.filter { species in
      species.name.lowercased().contains(searchText.lowercased()) ||
      species.scientificName.lowercased().contains(searchText.lowercased())
    }

    // Apply other filters
    filteredList = applyFilter(to: filteredList, with: filterOption)
    filteredList = applyRarityFilter(to: filteredList, with: rarityFilterOption)
    // Apply latest filter
    return applyBookmarkFilter(to: filteredList, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray.records)
  }

  private func applyFilter(to species: [Species], with filterOption: FilterAllOption) -> [Species] {
    switch filterOption {
    case .all:
      return species
    case .native:
      return species.filter { $0.native }
    }
  }

  private func applyRarityFilter(to species: [Species], with filterOption: FilteringRarityOption) -> [Species] {
    switch filterOption {
    case .all:
      return species
    case .common:
      return species.filter { $0.rarity == 1 }
    case .uncommon:
      return species.filter { $0.rarity == 2 }
    case .rare:
      return species.filter { $0.rarity == 3 }
    case .veryRare:
      return species.filter { $0.rarity == 4 }
    }
  }

  private func applyBookmarkFilter(to species: [Species], isBookmarked: Bool, additionalIntArray: [BookMark]) -> [Species] {
    if isBookmarked {
      return species.filter { species in
        additionalIntArray.contains(where: { $0.speciesID == species.speciesId })
      }
    } else {
      return species
    }
  }
}
