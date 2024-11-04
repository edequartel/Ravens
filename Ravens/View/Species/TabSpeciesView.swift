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
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel
    @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
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

            NavigationLink(
              destination:
                SpeciesView(
                  item: species,
                  selectedSpeciesID: $selectedSpeciesID)

            ) { SpeciesInfoView(
              species: species,
              showView: showView,
              bookMarksViewModel: bookMarksViewModel,
              speciesSecondLangViewModel: speciesSecondLangViewModel)

            }


            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button(action: {
//                selectedSpeciesID = species.id
                selectedSpeciesID = species.species_id
              }) {
                Image(systemName: "info.circle")
              }
              .tint(.blue)

              Button(action: {
//                if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.id) {
//                  print("bookmarks remove")
//                  bookMarksViewModel.removeRecord(speciesID: species.id)
//                } else {
//                  bookMarksViewModel.appendRecord(speciesID: species.id)
//                  print("bookmarks append")
//                }

                if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.species_id) {
                  print("bookmarks remove")
                  bookMarksViewModel.removeRecord(speciesID: species.species_id)
                } else {
                  bookMarksViewModel.appendRecord(speciesID: species.species_id)
                  print("bookmarks append")
                }

              } ) {
                Image(systemName: "star")
              }
              .tint(.obsStar)
            }
          }
        }
        .listStyle(PlainListStyle())

      }

      .toolbar {
        // First Menu for Sorting
        ToolbarItem(placement: .navigationBarTrailing) {
          SortNameMenu(currentFilteringNameOption: $selectedSortOption)
        }
        // Second Menu for Filtering
//        ToolbarItem(placement: .navigationBarTrailing) {
//          FilteringAllMenu(currentFilteringAllOption: $selectedFilterOption)
//        }
        ToolbarItem(placement: .navigationBarTrailing) {
          FilteringMenu(currentFilteringOption: $selectedRarityOption)
        }
      }

      .navigationBarTitle(settings.selectedSpeciesGroupName)
      .navigationBarTitleDisplayMode(.inline)

      .navigationBarItems(
        leading: HStack {
          Button(action: {
            settings.isBookMarkVisible.toggle()
          }) {
            Image(systemName: settings.isBookMarkVisible ? "star.fill" : "star")
              .foregroundColor(.blue)
          }
          .accessibilityLabel(settings.isBookMarkVisible ? "alleen favorieten" : "alles")
          .accessibilityHint("soorten kun je favoriet maken, door een actie, en hier kun je dan op filteren.")

//          Button(action: {
//            settings.isLatestVisible.toggle()
//          }) {
//            Image(systemName: settings.isLatestVisible ? "circle.hexagonpath.fill" : "circle.hexagonpath")
//          }
//          .accessibilityLabel(settings.isLatestVisible ? "alleen zeldzaamheden" : "alles")
//          .accessibilityHint("je kunt filteren op zeldzaamheden, wanneer deze actief is worden alleen de zeldzaamheden in de lijst getoond.")

        }
      )

    }
    .searchable(text: $searchText)
    .refreshable {
      print("refresh deze in realtime laten uitvoeren")
      speciesViewModel.parseHTMLFromURL(
        settings: settings,
        completion: {
          print("parsed from html")
          //update the view
//          speciesViewModel.objectWillChange.send()
        })
    }
  }

    var searchResults: [Species] {
        if searchText.isEmpty {
            return speciesViewModel.sortedSpecies(by: selectedSortOption)
        } else {
            return speciesViewModel.sortedSpecies(by: selectedSortOption).filter {
                $0.name.contains(searchText) || $0.scientific_name.contains(searchText)
            }
        }
    }

}


enum SortNameOption: String, CaseIterable {
    case name = "Name"
    case scientific_name = "Scientific name"
    // Add more sorting options if needed
  case lastSeen = "Last seen"
}

struct SortNameMenu: View {
    @Binding var currentFilteringNameOption: SortNameOption

    var body: some View {
        NavigationLink(destination: SortNameOptionsView(currentFilteringNameOption: $currentFilteringNameOption)) {
            Image(systemName: "arrow.up.arrow.down")
                .accessibilityElement(children: .combine)
                .accessibility(label: Text("Filtering"))
        }
        .accessibility(label: Text("Menu Sort"))
    }
}

struct SortNameOptionsView: View {
  @Binding var currentFilteringNameOption: SortNameOption

  var body: some View {
    if showView { Text("SortNameOptionsView").font(.customTiny) }
    Form {
      Section("Sort") {
        List(SortNameOption.allCases, id: \.self) { option in
          Button(action: {
            currentFilteringNameOption = option
          }) {
            HStack {
              Text(option.rawValue)
              Spacer()
              if currentFilteringNameOption == option {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
    }
  }
}


enum FilterAllOption: String, CaseIterable {
    case all = "All"
    case native = "Native"
    // Add more filter options if needed
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
    Form {
      Section("Filter") {
        List(FilterAllOption.allCases, id: \.self) { option in
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
            species.scientific_name.lowercased().contains(searchText.lowercased())
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
                additionalIntArray.contains(where: { $0.speciesID == species.species_id })
            }
        } else {
            return species
        }
    }
}

struct SpeciesInfoView: View {
    var species: Species // Assuming Species is your data model
    var showView: Bool
//    var htmlViewModel: HTMLViewModel // Assuming HTMLViewModel is your ViewModel
    var bookMarksViewModel: BookMarksViewModel // Assuming BookMarksViewModel is your ViewModel
    var speciesSecondLangViewModel: SpeciesViewModel // Assuming SpeciesSecondLangViewModel is your ViewModel

  var body: some View {
    VStack(alignment: .leading) {
      if showView { Text("SpeciesInfoView").font(.customTiny) }
      HStack(spacing: 4) {
        if let date = species.date {
          Image(
            systemName: "eye")
          .symbolRenderingMode(.palette)
          .foregroundStyle(rarityColor(value: species.rarity), .clear)
        } else {
          Image(
            systemName: "circle.fill")
          .symbolRenderingMode(.palette)
          .foregroundStyle(rarityColor(value: species.rarity), .clear)

        }

        Text("\(species.name)")
          .bold()
          .lineLimit(1)
          .truncationMode(.tail)
        Spacer()
//        if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.id) {
        if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.species_id) {
          Image(systemName: "star.fill")
        }
      }

      if let date = species.date {
          HStack {
              Text("\(date)") // Date exists
              Text("\(species.time ?? "noTime")")
              Text("\(species.nrof ?? 0)x")
              Spacer()
          }
          .font(.caption)
      }

      HStack {
        Text("\(species.scientific_name)")
          .font(.caption)
          .italic()
          .lineLimit(1)
          .truncationMode(.tail)
      }
      HStack{
        let speciesLang = speciesSecondLangViewModel.findSpeciesByID(
//          speciesID: species.id)
          speciesID: species.species_id)
        Text("\(speciesLang ?? "placeholder")")
//          .bold()
          .font(.caption)
          .lineLimit(1)
          .truncationMode(.tail)
        Spacer()
      }
    }
  }
}
