//
//  BirdView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct BirdView: View {
    let log = SwiftyBeaver.self
    @StateObject private var viewModel = BirdViewModel()
    
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    
    @State private var selectedSortOption: SortOption = .name
    @State private var selectedFilterOption: FilterOption = .all
    @State private var selectedRarityFilterOption: RarityFilterOption = .all
    
    @EnvironmentObject var settings: Settings
    
    @State private var searchText = ""
    @State private var isObservationSheetPresented = false
    @State private var isMapObservationSheetPresented = false
    
    @State private var birdId = 1
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredBirds(by: selectedSortOption, searchText: searchText, filterOption: selectedFilterOption, rarityFilterOption: selectedRarityFilterOption), id: \.species) { bird in
                    // Display your bird information here
                    NavigationLink(destination: SpeciesDetailsView(speciesID: bird.id)) {
                        HStack { Image(systemName: "circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(myColor(value: bird.rarity), .clear)
                        }
                        VStack(alignment: .leading) {
                            Text("\(bird.id) \(bird.name)")
                                .bold()
                            
                            Text("\(bird.scientific_name)")
                                .italic()
                            // Additional information if needed
                        }
                    }
                    .swipeActions {
                        Button(action: {
                            log.verbose("call isObservationSheetPresented with bird.id \(bird.id)")
                            birdId = bird.id
                            isObservationSheetPresented.toggle()
                        }) {
                            Image(systemName: "list.bullet") // Replace "eye" with the system image name you want
                                .foregroundColor(.blue) // You can customize the color
                                .font(.title) // You can customize the font size
                                .padding() // You can customize the padding
                        }
                        .tint(.green)
                        
                        Button(action: {
                            log.verbose("call isMapObservationSheetPresented with bird.id \(bird.id)")
                            birdId = bird.id
                            isMapObservationSheetPresented.toggle()
                        }) {
                            Image(systemName: "map.fill") // Replace "eye" with the system image name you want
                                .foregroundColor(.blue) // You can customize the color
                                .font(.title) // You can customize the font size
                                .padding() // You can customize the padding
                        }
                        .tint(.orange)
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
                    
                    Picker("Filter rarity by", selection: $selectedRarityFilterOption) {
                        Text("All").tag(RarityFilterOption.all)
                        Text("Common").tag(RarityFilterOption.common)
                        Text("Uncommon").tag(RarityFilterOption.uncommon)
                        Text("Rare").tag(RarityFilterOption.rare)
                        Text("Very rare").tag(RarityFilterOption.veryrare)
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationBarTitle(settings.selectedGroupString, displayMode: .inline)
            
            
        }
        .sheet(isPresented: $isObservationSheetPresented, content: {
            ObservationsSpeciesView(speciesID: birdId)
        })
        .sheet(isPresented: $isMapObservationSheetPresented, content: {
            MapObservationsSpeciesView(speciesID: birdId)
        })
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
        let observationsSpeciesViewModel = ObservationsSpeciesViewModel()
        let settings = Settings()
        
        // Setting up the environment objects for the preview
        BirdView()
            .environmentObject(observationsViewModel)
            .environmentObject(observationsSpeciesViewModel)
            .environmentObject(settings)
    }
}
