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
    
    let minimumRadius = 500.0
    let maximumRadius = 5000.0
    let step = 500.0
    
    var body: some View {
        
        NavigationStack {
            Form {
                Section("species".localized()) {
                    Picker("group".localized(), selection: $settings.selectedSpeciesGroup) {
                        ForEach(speciesGroupViewModel.speciesGroups.sorted(by: {$0.name < $1.name}), id: \.id) { speciesGroup in
                            Text("\(speciesGroup.name)")
                                .lineLimit(1) 
                                .truncationMode(.tail)
                        }
                    }
                    .onChange(of: settings.selectedSpeciesGroup) {
                        settings.selectedGroupId = settings.selectedSpeciesGroup
                        settings.selectedGroup = getId(region: settings.selectedRegion, groups: settings.selectedSpeciesGroup) ?? 1
                        settings.selectedGroupString = getGroup(id: settings.selectedSpeciesGroup) ?? "unknown".localized()
                    }
                }
                
                Section("map".localized()) {
                    Toggle("poi".localized(), isOn: $settings.poiOn)

                    Picker("days".localized(), selection: $settings.days) {
                        ForEach(1 ... 14, id: \.self) { day in
                            HStack() {
                                Text("\(day)")
                            }
                        }
                    }
                    
                    HStack {
                        Text("radius".localized())
                        Spacer()
                        Text("\(Int(settings.radius)) m")
                    }
                    
                    Slider(value: Binding(get: {
                        Double(settings.radius)
                    }, set: {
                        settings.radius = Int($0)
                    }), in: Double(minimumRadius)...Double(maximumRadius), step: step)
                    .padding()
                    
                }
            }
            .navigationTitle("settings".localized())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ManualView()) {
                        Label("manual".localized(), systemImage: "info.circle")
                    }
                }
            }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let settings = Settings()

        // Setting up the environment objects for the preview
        SettingsView()
            .environmentObject(settings)
    }
}
