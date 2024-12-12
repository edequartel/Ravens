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

  @EnvironmentObject var speciesViewModel: SpeciesViewModel 

  @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel


  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var settings: Settings
  
  @State private var selectedSortOption: SortNameOption = .lastSeen
  @State private var selectedFilterOption: FilterAllOption = .all
  @State private var selectedRarityOption: FilteringRarityOption = .all
  @State private var searchText = ""
  
  @Binding var selectedSpeciesID: Int?

  var body: some View {
    NavigationView {
      
      VStack {
        if showView { Text("TabSpeciesView").font(.customTiny) }
        HorizontalLine()
        List {
          ForEach(speciesViewModel.filteredSpecies(
            by: selectedSortOption,
            searchText: searchText,
            filterOption: selectedFilterOption,
            rarityFilterOption: selectedRarityOption,
            isLatest: false, //settings.isLatestVisible,
            isBookmarked: settings.isBookMarkVisible,
            additionalIntArray: bookMarksViewModel
          ), id: \.id) { species in
            
            
            NavigationLink( //???
              destination: SpeciesView(
                observationsSpecies: observationsSpecies,
                item: species,
                selectedSpeciesID: $selectedSpeciesID)
            ) {
              SpeciesInfoView(
                species: species,
                showView: showView)

            }

            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button(action: {
                selectedSpeciesID = species.speciesId
              }) {
                Image(systemSymbol: .infoCircle)
              }
              .tint(.blue)
              
              Button(action: {
                if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.speciesId) {
                  bookMarksViewModel.removeRecord(speciesID: species.speciesId)
                } else {
                  bookMarksViewModel.appendRecord(speciesID: species.speciesId)
                }
                
              } ) {
                Image(systemSymbol: .star)
              }
              .tint(.obsStar)
            }
            .background(Color.gray.opacity(0.1))
            .accessibilityLabel(species.name)
          }
        }
        .listStyle(PlainListStyle())
        .searchable(text: $searchText) //een niveau lager geplaatst
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: SortFilterSpeciesView(
            selectedSortOption: $selectedSortOption,
            selectedFilterAllOption: $selectedFilterOption,
            selectedRarityOption: $selectedRarityOption
          )) {
            Image(systemSymbol: .ellipsisCircle)
              .uniformSize(color: .orange)
              .accessibility(label: Text(sortAndFilterSpecies))
          }
        }
      }
      
      .navigationBarTitle(settings.selectedSpeciesGroupName)
      .navigationBarTitleDisplayMode(.inline)
      
      .navigationBarItems(
        leading: HStack {
          Button(action: {
            settings.isBookMarkVisible.toggle()
          }) {
            Image(systemSymbol: settings.isBookMarkVisible ? .starFill : .star)
              .uniformSize(color: .cyan)
          }
          .accessibilityLabel(settings.isBookMarkVisible ? favoriteVisible : allVisible)
        }
      )
      
    }
    .refreshable {
//      speciesViewModel.fillSpecies()
      speciesViewModel.parseHTMLFromURL(
        settings: settings,
        completion: {
          log.error("from refreshable... parsed from html")
        })
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
  
  var body: some View {
    Form {
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

enum SortNameOption: String, CaseIterable {
  case name
  case scientificName
  case lastSeen

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


enum FilterAllOption: String, CaseIterable {
  case all
  case native
  // Add more filter options if needed
  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
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
      //        default:
      //            return species
    }
  }
  
  private func applyBookmarkFilter(to species: [Species], isBookmarked: Bool, additionalIntArray: [BookMark]) -> [Species] {
    if isBookmarked {
      return species.filter { species in
        //                additionalIntArray.contains(where: { $0.speciesID == species.id })
        additionalIntArray.contains(where: { $0.speciesID == species.speciesId })
      }
    } else {
      return species
    }
  }
}

