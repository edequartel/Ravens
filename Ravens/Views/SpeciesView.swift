//
//  SpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver
//import Popovers


struct SpeciesView: View {
    let log = SwiftyBeaver.self
    @StateObject private var speciesViewModel = SpeciesViewModel(settings: Settings())
    
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var selectedSortOption: SortOption = .name
    @State private var selectedFilterOption: FilterOption = .native
    
    @State private var searchText = ""
    @State private var speciesId : Int?
    
    // @State private var isPopupVisible = false <== bindable
    
    @State private var isBookMarksVisible = false
    @State private var bookMarks: [Int] = []
    
    // Function to check if a number is in the array
    func isNumberInBookMarks(number: Int) -> Bool {
        return bookMarks.contains(number)
    }
    
    //
    var body: some View {
        NavigationStack {
           List {
                ForEach(speciesViewModel.filteredSpecies(by: selectedSortOption, searchText: searchText, filterOption: selectedFilterOption, rarityFilterOption: settings.selectedRarity, isBookmarked: settings.isBookMarkVisible, additionalIntArray: bookMarks), id: \.species) { species in
                    HStack {
                        HStack {
                            NavigationLink(destination: MapObservationsSpeciesView(speciesID: species.id, speciesName: species.name)) {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "circle.fill")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(myColor(value: species.rarity), .clear)

                                        //are there any observations
                                        if (!keyChainViewModel.token.isEmpty) {
                                            ObservationDetailsView(speciesID: species.id)
                                        }
                                        
                                        Text(" \(species.name)")
                                            .bold()
                                            .lineLimit(1) // Set the maximum number of lines to 1
                                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                                        Spacer()
                                        if isNumberInBookMarks(number: species.id) {
                                            Image(systemName: "bookmark")
                                        }
                                    }
                                    HStack {
                                        Text("\(species.scientific_name)")
                                            .italic()
                                            .lineLimit(1) // Set the maximum number of lines to 1
                                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                                    }
                                }
                                .onLongPressGesture(minimumDuration: 1) {
                                    log.verbose("onLONGTapgesture \(species.id)")
                                    speciesId = species.id
                                    //
                                    if isNumberInBookMarks(number: species.id) {
                                        if let index = bookMarks.firstIndex(of: species.id) {
                                            bookMarks.remove(at: index)
                                            settings.saveBookMarks(array: bookMarks)
                                            print(bookMarks)
                                        }
                                    } else
                                    {
                                        bookMarks.append(species.id)
                                        settings.saveBookMarks(array: bookMarks)
                                        print(bookMarks)
                                    }
                                    //
                                    
                                }
                                .onAppear() {
                                    speciesId = species.id
                                    log.verbose("onAppear \(species.id)")
                                }
                                
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
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
                        Text("All").tag(0)
                        Text("Common").tag(1)
                        Text("Uncommon").tag(2)
                        Text("Rare").tag(3)
                        Text("Very rare").tag(4)
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationBarTitle("\(speciesGroupViewModel.getName(forID: settings.selectedSpeciesGroup) ?? "unknown")", displayMode: .inline) //?
            
            .navigationBarItems(
                leading: HStack {
                    
                    Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                        .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .blue)
                    NetworkView()
                    Button(action: {
                        settings.isBookMarkVisible.toggle()
                    }) {
                        Image(systemName: settings.isBookMarkVisible ? "bookmark" : "bookmark.slash")
                            .foregroundColor(.blue)
                    }
                }
            )
            
        }
        .searchable(text: $searchText)
        
        .onAppear() {
            log.info("speciesView: selectedGroup \(settings.selectedGroup)")
            
            speciesViewModel.fetchData(language: settings.selectedLanguage, for: settings.selectedGroup)
   
            speciesGroupViewModel.fetchData(language: settings.selectedLanguage, completion: { success in
                log.info("speciesGroupViewModel.fetchData completed")
            })
            
            settings.readBookmarks(array: &bookMarks)
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
    func filteredSpecies(by sortOption: SortOption, searchText: String, filterOption: FilterOption, rarityFilterOption: Int, isBookmarked: Bool, additionalIntArray: [Int]) -> [Species] {
        let sortedSpeciesList = sortedSpecies(by: sortOption)
        
        if searchText.isEmpty {
            var filteredList = applyFilter(to: sortedSpeciesList, with: filterOption)
            filteredList = applyRarityFilter(to: filteredList, with: rarityFilterOption)
            return applyBookmarkFilter(to: filteredList, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray)
        } else {
            let filteredList = sortedSpeciesList.filter { species in
                species.name.lowercased().contains(searchText.lowercased()) ||
                species.scientific_name.lowercased().contains(searchText.lowercased())
            }
            
            var filtered = applyFilter(to: filteredList, with: filterOption)
            filtered = applyRarityFilter(to: filtered, with: rarityFilterOption)
            return applyBookmarkFilter(to: filtered, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray)
        }
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
            return species.filter { $0.rarity == 2}
        case 3:
            return species.filter { $0.rarity == 3 }
        case 4:
            return species.filter { $0.rarity == 4 }
        default:
            return species
        }
    }
    
    private func applyBookmarkFilter(to species: [Species], isBookmarked: Bool, additionalIntArray: [Int]) -> [Species] {
        if isBookmarked {
            return species.filter { additionalIntArray.contains($0.id) }
        } else {
            return species
        }
    }
}


struct SpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        SpeciesView()
            .environmentObject(ObservationsViewModel(settings: Settings()))
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
            .environmentObject(KeychainViewModel())
            .environmentObject(Settings())
    }
}

