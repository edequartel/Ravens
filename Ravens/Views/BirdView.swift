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
    @StateObject private var birdViewModel = BirdViewModel()
    
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var selectedSortOption: SortOption = .name
    @State private var selectedFilterOption: FilterOption = .native
    @State private var selectedRarityFilterOption: RarityFilterOption = .rare
    
    @State private var searchText = ""
    @State private var isMapObservationSheetPresented = false
    @State private var birdId : Int?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(birdViewModel.filteredBirds(by: selectedSortOption, searchText: searchText, filterOption: selectedFilterOption, rarityFilterOption: selectedRarityFilterOption), id: \.species) { bird in

                    NavigationLink(destination: MapObservationsSpeciesView(speciesID: bird.id, speciesName: bird.name)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(myColor(value: bird.rarity), .clear)
                                ObservationDetailsView(speciesID: bird.id)
                                Text("\(bird.id) \(bird.name)")
                                    .bold()
                                    .lineLimit(1) // Set the maximum number of lines to 1
                                    .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                            }
                            HStack {
                                Text("\(bird.scientific_name)")
                                    .italic()
                                    .lineLimit(1) // Set the maximum number of lines to 1
                                    .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated

                            }
                        }
                        .onTapGesture() {
                            log.verbose("onTapgesture \(bird.id)")
                            birdId = bird.id
                        }
                        .onAppear() {
                            birdId = bird.id
                            log.verbose("onAppear \(bird.id)")
                        }
                        
                    }
                    .contentShape(Rectangle())
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
        .searchable(text: $searchText)
        .onAppear() {
            log.error("birdview: selectedGroup \(settings.selectedGroup)")
            birdViewModel.fetchData(for: settings.selectedGroup, language: settings.selectedLanguage)
        }
    }
    
    var searchResults: [Bird] {
        if searchText.isEmpty {
            return birdViewModel.sortedBirds(by: selectedSortOption)
        } else {
            return birdViewModel.sortedBirds(by: selectedSortOption).filter {
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
            return birds.filter { $0.rarity >= 1 }
        case .uncommon:
            return birds.filter { $0.rarity >= 2}
        case .rare:
            return birds.filter { $0.rarity >= 3 }
        case .veryrare:
            return birds.filter { $0.rarity >= 4 }
            
        }
    }
}

struct BirdView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        BirdView()
            .environmentObject(ObservationsViewModel())
            .environmentObject(ObservationsSpeciesViewModel())
            .environmentObject(Settings())
    }
}



//                        Button(action: {
//                            log.verbose("call isObservationsSpeciesViewPresented with bird.id \(bird.id)")
//                            birdId = bird.id
//                            isObservationsSpeciesViewPresented.toggle()
//                        }) {
//                            Image(systemName: "list.bullet") // Replace "eye" with the system image name you want
//                                .foregroundColor(.blue) // You can customize the color
//                                .font(.title) // You can customize the font size
//                                .padding() // You can customize the padding
//                        }
//                        .tint(.green)


//Text("\(bird.id) \(bird.name)")
//    .onAppear() {
//        // Handle tap gesture for the bird
//        birdId = bird.id
//        print(">> \(birdId)")
//    }
//    .onTapGesture {
//        // Handle tap gesture for the bird
//        birdId = bird.id
//        print("-- \(birdId)")
//    }
//}
