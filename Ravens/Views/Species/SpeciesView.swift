//
//  SpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct SpeciesView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel
    
    @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
    
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var selectedSortOption: SortOption = .name
    @State private var selectedFilterOption: FilterOption = .native
    
    @State private var searchText = ""
    @State private var selectedInfoItem: Species?
    @State private var selectedMapItem: Species?
    @State private var selectedListItem: Species?
    @State private var selectedListMapItem: Species?
    @State private var showFirstView = true
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(speciesViewModel.filteredSpecies( //?
                        by: selectedSortOption,
                        searchText: searchText,
                        filterOption: selectedFilterOption,
                        rarityFilterOption: settings.selectedRarity,
                        isBookmarked: settings.isBookMarkVisible,
                        additionalIntArray: bookMarksViewModel)
                            
//                        .filter { result in
//                            ((!settings.showObsPictures) && (!settings.showObsAudio)) ||
//                            (
//                                (result.has_photo ?? false) && (settings.showObsPictures) ||
//                                (result.has_sound ?? false) && (settings.showObsAudio)
//                            )
//                        }
                            
                            
                            
                            
                            , id: \.species) { species in
                        
                        NavigationLink(destination: TabSpeciesView(item: species)) {
                            
                            VStack(alignment: .leading) {
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(myColor(value: species.rarity), .clear)
                                    
                                    
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
                                self.selectedInfoItem = species
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
            
            .navigationBarTitle(settings.selectedSpeciesGroupName)
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationBarItems(
                leading: HStack {
                    
                    //                    Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                    //                        .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .blue)
                    NetworkView()
                    Button(action: {
                        settings.isBookMarkVisible.toggle()
                    }) {
                        Image(systemName: settings.isBookMarkVisible ? "star.fill" : "star")
                            .foregroundColor(.blue)
                    }
                    
//                    Button(action: {
//                       NavigationLink(destination: HTMLView(), label: "Rarity")
//                        
//                    }) {
//                        Image(systemName: "map")
//                    }
                    
                }
            )
            
        }
        .searchable(text: $searchText)
        
        
        .sheet(item: $selectedInfoItem) { item in
            SpeciesDetailsView(speciesID: item.id)
            //            Text("SpeciesDetailsView \(item.id)")
        }
        
        .sheet(item: $selectedMapItem) { item in
            if settings.listPreference {
                ObservationsSpeciesView(item: item)
            } else {
                MapObservationsSpeciesView(item: item)
            }
        }
        
        .sheet(item: $selectedListMapItem) { item in
            if settings.listPreference {
                ObservationsSpeciesView(item: item)
            } else {
                MapObservationsSpeciesView(item: item)
            }
        }
        
        .sheet(item: $selectedMapItem) { item in
            MapObservationsSpeciesView(item: item)
        }
        
        .sheet(item: $selectedListItem) { item in
            ObservationsSpeciesView(item: item)
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
    func filteredSpecies(by sortOption: SortOption, searchText: String, filterOption: FilterOption, rarityFilterOption: Int, isBookmarked: Bool, additionalIntArray: BookMarksViewModel) -> [Species] {
        let sortedSpeciesList = sortedSpecies(by: sortOption)
        
        if searchText.isEmpty {
            var filteredList = applyFilter(to: sortedSpeciesList, with: filterOption)
            filteredList = applyRarityFilter(to: filteredList, with: rarityFilterOption)
            return applyBookmarkFilter(to: filteredList, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray.records)
        } else {
            let filteredList = sortedSpeciesList.filter { species in
                species.name.lowercased().contains(searchText.lowercased()) ||
                species.scientific_name.lowercased().contains(searchText.lowercased())
            }
            
            var filtered = applyFilter(to: filteredList, with: filterOption)
            filtered = applyRarityFilter(to: filtered, with: rarityFilterOption)
            return applyBookmarkFilter(to: filtered, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray.records)
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
    
    private func applyBookmarkFilter(to species: [Species], isBookmarked: Bool, additionalIntArray: [BookMark]) -> [Species] {
        if isBookmarked {
            return species.filter { species in additionalIntArray.contains(where: { $0.speciesID == species.id }) }
        } else {
            return species
        }
    }
    
    
}

//struct SpeciesView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Setting up the environment objects for the preview
//        SpeciesView()
//            .environmentObject(ObservationsViewModel())
//            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
////            .environmentObject(SpeciesGroupViewModel())
//            .environmentObject(KeychainViewModel())
//            .environmentObject(Settings())
//    }
//}
//
