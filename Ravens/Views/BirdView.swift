//
//  BirdView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

struct BirdView: View {
    @StateObject private var viewModel = BirdViewModel()
    
    @State private var selectedSortOption: SortOption = .name
    @State private var selectedFilterOption: FilterOption = .native
    @State private var selectedRarityFilterOption: RarityFilterOption = .common

    @EnvironmentObject var settings: Settings
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredBirds(by: selectedSortOption, searchText: searchText, filterOption: selectedFilterOption, rarityFilterOption: selectedRarityFilterOption), id: \.species) { bird in
                    // Display your bird information here
                    NavigationLink(destination: SpeciesDetailsView(speciesID: bird.id)) {
                        VStack(alignment: .leading) {
                            Text("\(bird.name)")
                                .bold()
                            Text("\(bird.scientific_name)")
                                .italic()
                            // Additional information if needed
                            //                            Text("\(bird.rarity)")
                            //                            Text(bird.native ? "inheems" : "exoot")
                        }
                    }
                }
            }
            .toolbar{
                Menu("sort".localized(), systemImage: "arrow.up.arrow.down") {
                    Picker("sortby".localized(), selection: $selectedSortOption) {
                        Text("name".localized()).tag(SortOption.name)
                        Text("scientificname".localized()).tag(SortOption.scientific_name)
                        // Add more sorting options if needed
                    }
                    .pickerStyle(.inline)
                    
                    Picker("filterby", selection: $selectedFilterOption) {
                        Text("all".localized()).tag(FilterOption.all)
                        Text("native".localized()).tag(FilterOption.native)
                        // Add more filter options if needed
                    }
                    .pickerStyle(.inline)
                    
                    Picker("filterrarityby", selection: $selectedRarityFilterOption) {
                        Text("all".localized()).tag(RarityFilterOption.all)
                        Text("common".localized()).tag(RarityFilterOption.common)
                        Text("uncommon".localized()).tag(RarityFilterOption.uncommon)
                        Text("rare".localized()).tag(RarityFilterOption.rare)
                        Text("veryrare".localized()).tag(RarityFilterOption.veryrare)
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationBarTitle(settings.selectedGroupString, displayMode: .inline)

            
        }
        .searchable(text: $searchText)
        .onAppear() {
            viewModel.fetchData(for: settings.selectedGroup)
        }
    }
    
    var searchResults: [Bird] {
        if searchText.isEmpty {
            return viewModel.sortedBirds(by: selectedSortOption)
        } else {
            return viewModel.sortedBirds(by: selectedSortOption).filter {
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

enum RarityFilterOption: Int {
    case all = 0
    case common = 1
    case uncommon = 2
    case rare = 3
    case veryrare = 4
    
    var shape: some ShapeStyle {
        switch self {
        case .all:
            return Color(UIColor.systemGray)
        case .common:
            return Color(UIColor.systemGreen)
        case .uncommon:
            return Color(UIColor.systemBlue)
        case .rare:
            return Color(UIColor.systemOrange)
        case .veryrare:
            return Color(UIColor.systemRed)
        }
    }
}


extension BirdViewModel {
    func sortedBirds(by sortOption: SortOption) -> [Bird] {
        switch sortOption {
        case .name:
            return birds.sorted { ($0.name < $1.name) }
        case .scientific_name:
            return birds.sorted { ($0.scientific_name < $1.scientific_name) }
            // Add more sorting options if needed
        }
    }
}

extension BirdViewModel {
    func filteredBirds(by sortOption: SortOption, searchText: String, filterOption: FilterOption, rarityFilterOption: RarityFilterOption) -> [Bird] {
        let sortedBirdsList = sortedBirds(by: sortOption)
        
        if searchText.isEmpty {
            let filteredList = applyFilter(to: sortedBirdsList, with: filterOption)
            let filtered  = applyFilter(to: filteredList, with: filterOption)
            return applyRarityFilter(to: filtered, with: rarityFilterOption)
            
        } else {
            let filteredList = sortedBirdsList.filter { bird in
                bird.name.lowercased().contains(searchText.lowercased()) ||
                bird.scientific_name.lowercased().contains(searchText.lowercased())
                // Add more fields if needed
            }
            
            let filtered  = applyFilter(to: filteredList, with: filterOption)
            return applyRarityFilter(to: filtered, with: rarityFilterOption)
            
        }
    }
    
    private func applyFilter(to birds: [Bird], with filterOption: FilterOption) -> [Bird] {
        switch filterOption {
        case .all:
            return birds
        case .native:
            return birds.filter { $0.native }
        }
    }
    
    private func applyRarityFilter(to birds: [Bird], with filterOption: RarityFilterOption) -> [Bird] {
        switch filterOption {
        case .all:
            return birds
        case .common:
            return birds.filter { $0.rarity == 1 }
        case .uncommon:
            return birds.filter { $0.rarity == 2}
        case .rare:
            return birds.filter { $0.rarity == 3 }
        case .veryrare:
            return birds.filter { $0.rarity == 4 }
            
        }
    }
}

struct BirdView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsViewModel = ObservationsViewModel()
        let settings = Settings() 

        // Setting up the environment objects for the preview
        BirdView()
            .environmentObject(observationsViewModel)
            .environmentObject(settings)
    }
}
