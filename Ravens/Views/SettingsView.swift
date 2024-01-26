//
//  SettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    
    @StateObject private var speciesGroupViewModel = SpeciesGroupViewModel()
    @StateObject private var regionsViewModel = RegionViewModel()
    @StateObject private var regionListViewModel = RegionListViewModel()
    
    @EnvironmentObject var settings: Settings
    

    
    
    let minimumRadius = 500.0
    let maximumRadius = 5000.0
    let step = 500.0
    
    //region netherlands - id=200, type=20
    //speciousgroup birds = 1
    //regionlist - regionid=200 speciesgroup=1 -->5001
    
    //regionlist - regionid=20 speciesgroup=1 --> 461
    var body: some View {
        
        NavigationStack {
            Form {
                
                
                
                Section("Species") {
                    Picker("Group", selection: $settings.selectedSpeciesGroup) {
                        ForEach(speciesGroupViewModel.speciesGroups.sorted(by: {$0.name < $1.name}), id: \.id) { speciesGroup in
                            Text("\(speciesGroup.name)")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .onChange(of: settings.selectedSpeciesGroup) {
                        settings.selectedGroupId = settings.selectedSpeciesGroup
                        settings.selectedGroup = getId(region: settings.selectedRegion, groups: settings.selectedSpeciesGroup) ?? 1
                        settings.selectedGroupString = getGroup(id: settings.selectedSpeciesGroup) ?? "unknown"
                    }
                }
                Section("Map") {
                    Toggle("Poi", isOn: $settings.poiOn)
                    
                    Picker("Rarity", selection: $settings.selectedRarity) {
                        ForEach(0..<5) { index in
                            Image(systemName: "bird.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(myColor(value: index), .clear)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: settings.selectedRarity) {
                        print(settings.selectedRarity)
                    }
                    
                    
                    HStack {
                        Text("Radius")
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
                Section("Days") {
                    
                    Picker("Window", selection: $settings.days) {
                        ForEach(1 ... 14, id: \.self) { day in
                            HStack() {
                                Text("\(day)")
                            }
                        }
                    }
                    
                    DatePicker("Date", selection: $settings.selectedDate, displayedComponents: [.date])
                        .onChange(of: settings.selectedDate) {
                            // Perform your action when the date changes
                            observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                                            lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                                            long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                                            radius: settings.radius,
                                                            species_group: settings.selectedGroupId,
                                                            min_rarity: settings.selectedRarity)
                        }
                }
                
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ManualView()) {
                        Label("Manual", systemImage: "info.circle")
                    }
                }
            }
        }
    }
    
    
    func getId(region: Int, groups: Int) -> Int? {
        print("\(region) \(groups)")
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
        let observationsViewModel = ObservationsViewModel()
        let settings = Settings()
        
        // Setting up the environment objects for the preview
        SettingsView()
            .environmentObject(settings)
            .environmentObject(observationsViewModel)
    }
}

