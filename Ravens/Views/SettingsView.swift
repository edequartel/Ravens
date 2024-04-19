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
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var regionsViewModel: RegionViewModel
    @EnvironmentObject var regionListViewModel: RegionListViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var storage: String = ""
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    let minimumRadius = 500.0
    let maximumRadius = 10000.0
    let step = 500.0
    
    var body: some View {
        
        NavigationStack {
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
                
                Section("Species") {
                    Picker("Group", selection: $settings.selectedSpeciesGroup) {
                        ForEach(speciesGroupViewModel.speciesGroups.sorted(by: {$0.name < $1.name}), id: \.id) { speciesGroup in
                            Text("\(speciesGroup.name)")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .onChange(of: settings.selectedSpeciesGroup) {
//                        settings.isFirstAppear = true
//                        settings.isFirstAppearObsView = true
                        settings.selectedGroupId = settings.selectedSpeciesGroup
                        log.info("\(speciesGroupViewModel.getName(forID: settings.selectedSpeciesGroup) ?? "unknown")")
                        settings.selectedGroup = getId(region: settings.selectedRegion, groups: settings.selectedSpeciesGroup) ?? 1
                        log.info("settings.selectedGroup \(settings.selectedGroup)")
                        speciesGroupViewModel.fetchData(language: settings.selectedLanguage, completion: { _ in log.error("speciesGroupViewModel.fetchData completed") })
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
//                    Toggle("Infinity (only location)", isOn: $settings.infinity)
//                        .onChange(of: settings.infinity) {
////                            settings.isFirstAppear = true
////                            settings.isFirstAppearObsView = true
//                        }
                    
                    
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
                    LanguageView(onChange: {upDate()})
                    ////                    RegionsView(onChange: {upDate()})
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
                            }
                        }
                    }
                    .font(.footnote)
                }
//                .font(.footnote)
                
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
        .onAppear() {
            storage = calculateLocalStorageSize()
            speciesGroupViewModel.fetchData(language: settings.selectedLanguage, completion: { _ in log.info("speciesGroupViewModel.fetchData completed") })
        }
        
    }
    
    func getId(region: Int, groups: Int) -> Int? {
        log.error("getID region: \(region) groups: \(groups)")
        if let matchingItem = regionListViewModel.regionLists.first(where: { $0.region == region && $0.species_group == groups }) {
            log.error("getId= \(matchingItem)")
            return matchingItem.id
        }
        log.error("getId: NIL")
        return nil
    }
    
    func getGroup(id: Int) -> String? {
        log.error("getGroup: \(id)")
        if let matchingItem = speciesGroupViewModel.speciesGroups.first(where: { $0.id == id } ) {
            log.error("getGroup= \(matchingItem)")
            return matchingItem.name
        }
        log.error("getGroup: NIL")
        return nil
    }
    
    func upDate() {
        log.verbose("update()")
        speciesGroupViewModel.fetchData(language: settings.selectedLanguage, completion: { _ in print ("update completed") })
        log.verbose("language: \(settings.selectedLanguage)")
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
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
    }
}

