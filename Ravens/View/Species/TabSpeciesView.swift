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
    @EnvironmentObject var htmlViewModel: HTMLViewModel
    @EnvironmentObject var settings: Settings

    @State private var selectedSortOption: SortOption = .name
    @State private var selectedFilterOption: FilterOption = .native
    @State private var searchText = ""

    @Binding var selectedSpeciesID: Int?


  var body: some View {
    NavigationView {
      
      VStack {
        if showView { Text("TabSpeciesView").font(.customTiny) }
        HorizontalLine()
        List {
          ForEach(
            speciesViewModel.filteredSpecies(
              by: selectedSortOption,
              searchText: searchText,
              filterOption: selectedFilterOption,
              
              rarityFilterOption: settings.selectedRarity,
              
              isLatest: settings.isLatestVisible,
              htmlViewModel: htmlViewModel,
              
              isBookmarked: settings.isBookMarkVisible,
              additionalIntArray: bookMarksViewModel)
            , id: \.species) { species in
              
              NavigationLink(
                destination:
                  SpeciesView(
                    item: species,
                    selectedSpeciesID: $selectedSpeciesID)
              ) {
                
                VStack(alignment: .leading) {
                  if showView { Text("xxxView").font(.customTiny) }
                  HStack(spacing: 4) {
                    
                    Image(
                      systemName: htmlViewModel.speciesScientificNameExists(species.scientific_name) ? "circle.hexagonpath.fill" : "circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(RarityColor(value: species.rarity), .clear)
                    
                    
                    Text("\(species.name)")// - \(species.id)") //?
                      .bold()
                      .lineLimit(1) // Set the maximum number of lines to 1
                      .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                    
                    Spacer()
                    if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.id) {
                      //                                        if isNumberInBookMarks(number: species.id) {
                      Image(systemName: "star.fill")
                    }
                  }
                  HStack {
                    Text("\(species.scientific_name)")
                      .italic()
                      .lineLimit(1) // Set the maximum number of lines to 1
                      .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                  }
                  HStack{
                    let speciesLang = speciesSecondLangViewModel.findSpeciesByID(
                      speciesID: species.id)//
                    //                                                                            if speciesLang != species.name {
                    Text("\(speciesLang ?? "placeholder")") //?
                      .bold()
                      .font(.caption)
                      .lineLimit(1) // Set the maximum number of lines to 1
                      .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                    Spacer()
                    //                                                                            }
                  }
                }
              }
              
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: {
                  selectedSpeciesID = species.id
                }) {
                  Image(systemName: "info.circle")
                }
                .tint(.blue)
                
                Button(action: {
                  if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.id) {
                    print("bookmarks remove")
                    bookMarksViewModel.removeRecord(speciesID: species.id)
                  } else {
                    bookMarksViewModel.appendRecord(speciesID: species.id)
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
      
      
      .toolbar{
        Menu("Sort/filter", systemImage: "arrow.up.arrow.down") {
          Picker("Sort by", selection: $selectedSortOption) {
            Text("Name").tag(SortOption.name)
            Text("Scientific name").tag(SortOption.scientific_name)
            // Add more sorting options if needed
          }
          .pickerStyle(.inline)
          
          Picker("Filter by", selection: $selectedFilterOption) {
            Text("All").tag(FilterOption.all)
            Text("Native").tag(FilterOption.native)
            // Add more filter options if needed
          }
          .pickerStyle(.inline)
          
          Picker("Filter rarity by", selection: $settings.selectedRarity) {
            Text(">= All").tag(0)
            Text("== Common").tag(1)
            Text("== Uncommon").tag(2)
            Text(">= Rare").tag(3)
            Text("== Very rare").tag(4)
          }
          .pickerStyle(.inline)
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
          
          Button(action: {
            settings.isLatestVisible.toggle()
          }) {
            Image(systemName: settings.isLatestVisible ? "circle.hexagonpath.fill" : "circle.hexagonpath")
          }
          .accessibilityLabel(settings.isLatestVisible ? "alleen zeldzaamheden" : "alles")
          .accessibilityHint("je kunt filteren op zeldzaamheden, wanneer deze actief is worden alleen de zeldzaamheden in de lijst getoond.")
          
        }
      )
      
    }
    .searchable(text: $searchText)
    .refreshable {
      htmlViewModel.parseHTMLFromURL(settings: Settings())
    }
    .onAppear() {
      htmlViewModel.parseHTMLFromURL(settings: Settings())
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

enum SortOption: String, CaseIterable {
    case name
    case scientific_name
    // Add more sorting options if needed
}

enum FilterOption: String, CaseIterable {
    case all
    case native
    // Add more filter options if needed
}

extension SpeciesViewModel {
    func sortedSpecies(by sortOption: SortOption) -> [Species] {
        switch sortOption {
        case .name:
            return species.sorted { ($0.name < $1.name) }
        case .scientific_name:
            return species.sorted { ($0.scientific_name < $1.scientific_name) }
            // Add more sorting options if needed
        }
    }
}

extension SpeciesViewModel {
    func filteredSpecies(
        by sortOption: SortOption,
        searchText: String,
        filterOption: FilterOption,
        rarityFilterOption: Int,
        isLatest: Bool,
        htmlViewModel: HTMLViewModel,
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
        filteredList = applyBookmarkFilter(to: filteredList, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray.records)

        // Apply latest filter
        return applyLatestFilter(to: filteredList, isLatest: isLatest, additionalHTMLDoc: htmlViewModel)
    }

    private func applyFilter(to species: [Species], with filterOption: FilterOption) -> [Species] {
        switch filterOption {
        case .all:
            return species
        case .native:
            return species.filter { $0.native }
        }
    }

    private func applyRarityFilter(to species: [Species], with filterOption: Int) -> [Species] {
        switch filterOption {
        case 0:
            return species
        case 1:
            return species.filter { $0.rarity == 1 }
        case 2:
            return species.filter { $0.rarity == 2 }
        case 3:
            return species.filter { $0.rarity >= 3 }
        case 4:
            return species.filter { $0.rarity == 4 }
        default:
            return species
        }
    }

    private func applyBookmarkFilter(to species: [Species], isBookmarked: Bool, additionalIntArray: [BookMark]) -> [Species] {
        if isBookmarked {
            return species.filter { species in
                additionalIntArray.contains(where: { $0.speciesID == species.id })
            }
        } else {
            return species
        }
    }

    private func applyLatestFilter(to species: [Species], isLatest: Bool, additionalHTMLDoc: HTMLViewModel) -> [Species] {
        if isLatest {
            return species.filter { species in
                additionalHTMLDoc.documents.contains(where: { $0.speciesScientificName == species.scientific_name })
            }
        } else {
            return species
        }
    }
}

//struct TabSpeciesView_Previews: PreviewProvider {
//    @State static var selectedSpecies: Species? = nil
////    @State static var selectedObservationSound: Observation? = nil
//    @State var selectedObservation: Observation?
//
//
//    static var previews: some View {
//        TabSpeciesView(
//          selectedSpecies: $selectedSpecies,
//          selectedObservation: $selectedObservation)
////          selectedObservationSound: $selectedObservationSound,
////          selectedObs: .constant(nil))
////          imageURLStr: .constant(""))
//            .environmentObject(SpeciesViewModel())
//            .environmentObject(SpeciesGroupsViewModel())
//            .environmentObject(ObservationsSpeciesViewModel())
//            .environmentObject(KeychainViewModel())
//            .environmentObject(BookMarksViewModel())
//            .environmentObject(HTMLViewModel())
//            .environmentObject(Settings())
//    }
//}
