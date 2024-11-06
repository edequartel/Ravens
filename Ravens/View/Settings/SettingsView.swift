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
  @EnvironmentObject var observationsRadiusViewModel: ObservationsRadiusViewModel
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
    NavigationStack {
      List {
        NavigationLink(destination: LoginView()) {
          Text("Login")
        }
        //      LoginView()
        
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
          //
//          LanguageView()
          
          Picker("Group", selection: $settings.selectedSpeciesGroupId) {
            ForEach(speciesGroupsViewModel.speciesGroupsByRegion, id: \.id) { speciesGroup in
              Text("\(speciesGroup.name)").tag(speciesGroup.id)
                .lineLimit(1)
                .truncationMode(.tail)
            }
          }
          .pickerStyle(.navigationLink)
          .onChange(of: settings.selectedSpeciesGroupId) {
            log.error("\(settings.selectedSpeciesGroupId)")
            settings.selectedRegionListId = regionListViewModel.getId(
              region: settings.selectedRegionId,
              speciesGroup: settings.selectedSpeciesGroupId)

            if let selectedGroup = speciesGroupsViewModel.speciesGroupsByRegion.first(where: {$0.id == settings.selectedSpeciesGroupId }) {
              settings.selectedSpeciesGroupName = selectedGroup.name
            }
            
            log.info("\(settings.selectedRegionListId) \(settings.selectedRegionId) \(settings.selectedSpeciesGroupId)")
            
            speciesViewModel.fetchDataFirst(settings: settings)
            speciesViewModel.fetchDataSecondLanguage(settings: settings)
            
          }
        }
        Section("Map") {
          Picker("Map Style", selection: $settings.mapStyleChoice) {
            ForEach(MapStyleChoice.allCases, id: \.self) { choice in
              Text(choice.rawValue.capitalized).tag(choice)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
        }
        Section(header: Text("App details")) {
          VStack(alignment: .leading) {
            Text(version())
            Text(locale.description)
          }
          .font(.footnote)
        }
        Section(header: Text("Location")) {
          VStack {
            LocationManagerView()
          }
        }
        
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }


  func getId(region: Int, species_group: Int) -> Int? {
    log.error("getID from regionListViewModel region: \(region) species_group: \(species_group)")
    if let matchingItem = regionListViewModel.regionLists.first(
      where: { $0.region == region && $0.speciesGroup == species_group }) {
      log.error("getId= \(matchingItem)")
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
      .environmentObject(ObservationsRadiusViewModel())
  }
}

