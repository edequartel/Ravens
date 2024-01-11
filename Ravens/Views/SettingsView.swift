//
//  SettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var speciesGroupViewModel = SpeciesGroupViewModel()
    @StateObject private var regionsViewModel = RegionViewModel()
    @StateObject private var regionListViewModel = RegionListViewModel()
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        
        NavigationStack {
            Form {
                
//                Picker("Region", selection: $settings.selectedRegion) {
//                    ForEach(regionsViewModel.regions, id:\.id) { region in
//                        HStack() {
//                            Text("\(region.name)")
//                        }
//                    }
//                }
//                .onChange(of: settings.selectedRegion) {
//                    settings.selectedGroup = getId(region: settings.selectedRegion,groups: settings.selectedSpeciesGroup) ?? 1
//                    settings.selectedGroupString = getGroup(id: settings.selectedSpeciesGroup) ?? "unknown"
//                }
                
                Picker("Group", selection: $settings.selectedSpeciesGroup) {
                    ForEach(speciesGroupViewModel.speciesGroups.sorted(by: {$0.name < $1.name}), id: \.id) { speciesGroup in
                        HStack() {
                            Text("\(speciesGroup.name)")
                        }
                    }
                }
                .onChange(of: settings.selectedSpeciesGroup) {
                    settings.selectedGroup = getId(region: settings.selectedRegion, groups: settings.selectedSpeciesGroup) ?? 1
                    settings.selectedGroupString = getGroup(id: settings.selectedSpeciesGroup) ?? "unknown"
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    
    func getId(region: Int, groups: Int) -> Int? {
        print("--> \(region) \(groups)")
        if let matchingItem = regionListViewModel.regionLists.first(where: { $0.region == region && $0.species_group == groups }) {
            print("= \(matchingItem)")
            return matchingItem.id
        }
        return nil
    }

    
    func getGroup(id: Int) -> String? {
        if let matchingItem = speciesGroupViewModel.speciesGroups.first(where: { $0.id == id } ) {
            print("= \(matchingItem)")
            return matchingItem.name
        }
        return nil
    }
    
}


#Preview {
    SettingsView()
}
