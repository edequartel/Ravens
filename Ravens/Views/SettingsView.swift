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
                
                Picker("Region", selection: $settings.selectedRegion) {
                    ForEach(regionsViewModel.regions, id:\.id) { region in
                        HStack() {
                            Text("\(region.name)")
                        }
                    }
                }
                .onChange(of: settings.selectedRegion) {
                    settings.selectedGroup = getId(region: settings.selectedRegion,groups: settings.selectedSpeciesGroup) ?? 1
                    print("\(settings.selectedSpeciesGroup) - \(settings.selectedGroup)")
                }
                
                Text("\(settings.selectedGroupString)")
                
                Picker("Group", selection: $settings.selectedSpeciesGroup) {
                    ForEach(Array(speciesGroupViewModel.speciesGroups.enumerated()), id: \.element.id) { index, speciesGroup in
                        HStack() {
                            Text("\(speciesGroup.id) - \(speciesGroup.name)")
                        }
                        .tag(index)
                    }
                }
                .onChange(of: settings.selectedSpeciesGroup) {tag in
                    
                    settings.selectedGroup = getId(region: settings.selectedRegion,groups: settings.selectedSpeciesGroup) ?? 1
                    print("[\(tag)]+selectedSpeciesGroup \(settings.selectedSpeciesGroup) - selectedGroup \(settings.selectedGroup)")
                    settings.selectedGroupString = "\(settings.selectedGroup) - \(speciesGroupViewModel.speciesGroups[tag].name)"
                }
                
            }
            .navigationTitle("Settings")
        }
    }
    
    
    func getId(region: Int, groups: Int) -> Int? {
        if let matchingItem = regionListViewModel.regionLists.first(where: { $0.region == region && $0.species_group == groups }) {
            return matchingItem.id
        }
        return nil
    }
}

#Preview {
    SettingsView()
}
