//
//  SettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct SettingsView: View {
    let log = SwiftyBeaver.self
    @Environment(\.locale) private var locale
    
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel   
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
    @EnvironmentObject var regionsViewModel: RegionsViewModel
    @EnvironmentObject var regionListViewModel: RegionListViewModel
    @EnvironmentObject var settings: Settings

    @State private var storage: String = ""
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    let minimumRadius = 500.0
    let maximumRadius = 10000.0
    let step = 500.0
    
    var body: some View {
        
        NavigationView {
            Button("printme") {
                if (speciesViewModel.species.count > 0) {
                    print(speciesViewModel.species[0].name)
                }
                
                if (speciesSecondLangViewModel.species.count > 0) {
                    print(speciesSecondLangViewModel.species[0].name)
                }
            }
            List {
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                }
                
                Picker("Source", selection: $settings.selectedInBetween) {
                    Text("waarneming.nl")
                        .tag("waarneming.nl")
                    Text("observation.org")
                        .tag("observation.org")
                }
                .pickerStyle(.inline)
                .onChange(of: settings.selectedInBetween) {
                }
                
                //edit: 27052024
                Section("Species") {
                    LanguageView()
                    RegionsView()
                    //
                    Picker("Group", selection: $settings.selectedSpeciesGroupId) {
                        ForEach(speciesGroupsViewModel.speciesGroupsByRegion, id: \.id) { speciesGroup in
//                                Text("\(speciesGroup.name)").tag(speciesGroup.id)
                                Text("\(speciesGroup.id) \(speciesGroup.name)").tag(speciesGroup.id)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                        }
                    }
                    .onChange(of: settings.selectedSpeciesGroupId) {
                        log.error("\(settings.selectedSpeciesGroupId)")
                        settings.selectedRegionListId = regionListViewModel.getId(
                            region: settings.selectedRegionId,
                            species_group: settings.selectedSpeciesGroupId)
                    }
                }
                
                Section("Map") {
                    Picker("Map Style", selection: $settings.mapStyleChoice) {
                        ForEach(MapStyleChoice.allCases, id: \.self) { choice in
                            Text(choice.rawValue.capitalized).tag(choice)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle("Poi", isOn: $settings.poiOn)
                    Toggle("Show observer", isOn: $settings.showUser)
                    Toggle("Radius", isOn: $settings.radiusPreference)
                    
                    Picker("Rarity", selection: $settings.selectedRarity) {
                        ForEach(0..<5) { index in
                            Image(systemName: "binoculars.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(myColor(value: index), .clear)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: settings.selectedRarity) {
                        log.info(settings.selectedRarity)
                    }
                    
                    if (settings.radiusPreference) {
                        HStack {
                            Text("Radius")
                            Spacer()
                            Text("\(Int(settings.radius)) m")
                        }
                    }
                    
                    if (settings.radiusPreference) {
                        Slider(value: Binding(get: {
                            Double(settings.radius)
                        }, set: {
                            settings.radius = Int($0)
                        }), in: Double(minimumRadius)...Double(maximumRadius), step: step)
                        .padding()
                    }
                    
                }
                
                Section("Days") {
                    if !(settings.radiusPreference) {
                        Toggle("Infinity (only location)", isOn: $settings.infinity)
                            .onChange(of: settings.infinity) {
                                //                            settings.isFirstAppear = true
                                //                            settings.isFirstAppearObsView = true
                            }
                    }
                    
                    
//                    if !(settings.infinity) {
                        Picker("Window", selection: $settings.days) {
                            ForEach(1 ... 14, id: \.self) { day in
                                HStack() {
                                    Text("\(day)")
                                }
                            }
                        }
                        .onChange(of: settings.days) {
//                            settings.isFirstAppear = true
//                            settings.isFirstAppearObsView = true
                        }
                        
                        DatePicker("Date", selection: $settings.selectedDate, displayedComponents: [.date])
                            .onChange(of: settings.selectedDate) {
                                // Perform your action when the date changes
                                observationsViewModel.fetchData(lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                                                long: settings.currentLocation?.coordinate.longitude ?? longitude, settings: settings,
                                                                completion:
                                                                    {
                                    log.info("fetchData observationsViewModel completed")
                                } )
                            }
                            .onChange(of: settings.selectedDate) {
//                                settings.isFirstAppear = true
//                                settings.isFirstAppearObsView = true
                            }
//                    }
                    
                    
                }
                
                Section("International") {
                    LanguageView()
                }
                
                
                Section(header: Text("App details")) {
                    Toggle("Save photos into album", isOn: $settings.savePhotos)
                    
                    VStack(alignment: .leading) {
                        Text(version())
                        Text(locale.description)
                        HStack {
                            Text("\(storage)")
                            Spacer()
                            Button("Cache Empty") {
                                deleteAllFiles()
                                storage = String(calculateLocalStorageSize())
                                log.error("cache is emptied")
                            }
                        }
                    }
                    .font(.footnote)
                }
                
                Section(header: Text("Location")) {
                    LocationManagerView()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ManualView()) {
                        Label("Manual", systemImage: "info.circle")
                    }
                }
                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: ObserversView()) {
//                        Label("Observers", systemImage: "person.3")
//                    }
//                }
            }
        }
        .onAppear() {
            storage = calculateLocalStorageSize()
//            speciesGroupViewModel.fetchData(language: settings.selectedLanguage)
        }
        
    }
    
    
    
    func getId(region: Int, species_group: Int) -> Int? {
        log.error("getID from regionListViewModel region: \(region) species_group: \(species_group)")
        if let matchingItem = regionListViewModel.regionLists.first(
            where: { $0.region == region && $0.species_group == species_group }) {
            log.error("---> getId= \(matchingItem)")
            return matchingItem.id
        }
        log.error("getId: NIL")
        return nil
    }
    
    func getGroup(id: Int) -> String? {
        log.error("getGroup: \(id)")
        if let matchingItem = speciesGroupsViewModel.speciesGroups.first(
            where: { $0.id == id } ) {
            log.error("getGroup= \(matchingItem)")
            return matchingItem.name
        }
        log.error("getGroup: NIL")
        return nil
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "Version \(version) build \(build)"
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        SettingsView()
            .environmentObject(Settings())
            .environmentObject(ObservationsViewModel())
//            .environmentObject(SpeciesGroupViewModel())
    }
}

