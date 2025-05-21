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
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
  @EnvironmentObject var regionsViewModel: RegionsViewModel
  @EnvironmentObject var regionListViewModel: RegionListViewModel
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var settings: Settings

  @State private var storage: String = ""

  let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

  let minimumRadius = 500.0
  let maximumRadius = 10000.0
  let step = 500.0

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Ravens")) {
          NavigationLink(destination: LoginView()) {
            Text("Login \(settings.selectedInBetween)")
          }
        }

        Picker(source, selection: $settings.selectedInBetween) {
          Text("waarneming.nl")
            .tag("waarneming.nl")
          Text("observation.org")
            .tag("observation.org")
        }
        .pickerStyle(.inline)
        .onChange(of: settings.selectedInBetween) {
        }

        Section {
          LanguageView()
        }

        Section(map) {
          Picker("Map Style", selection: $settings.mapStyleChoice) {
            ForEach(MapStyleChoice.allCases, id: \.self) { choice in
              Text(choice.localized).tag(choice)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
        }

        Section(header: Text(appDetails)) {
          VStack(alignment: .leading) {
            Text(version())
            Text(locale.description)
            Text(accessibilityManager.isVoiceOverEnabled ? "VoiceOver is ON" : "VoiceOver is OFF")
          }
          .font(.footnote)
          .padding(4)
          .accessibilityElement(children: .combine)
        }
      }
      .navigationTitle(settingsName)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if let url = URL(string: "https://www.ravensobs.com") {
              UIApplication.shared.open(url)
            }
          }) {
            Image(systemSymbol: .infoCircle)
              .uniformSize()
              .accessibilityLabel(information)
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if let url = URL(string: "https://www.ravensobs.com/manual.html") {
              UIApplication.shared.open(url)
            }
          }) {
            Image(systemSymbol: .questionmarkCircle)
              .uniformSize()
              .accessibilityLabel(information)
          }
        }
      }
    }
  }

  func getId(region: Int, speciesGroup: Int) -> Int? {
    log.verbose("getID from regionListViewModel region: \(region) species_group: \(speciesGroup)")
    if let matchingItem = regionListViewModel.regionLists.first(
      where: { $0.region == region && $0.speciesGroup == speciesGroup }) {
      log.error("getId= \(matchingItem)")
      return matchingItem.id
    }
    log.error("getId: NIL")
    return nil
  }

  func getGroup(id: Int) -> String? {
    log.error("getGroup: \(id)")
    if let matchingItem = speciesGroupsViewModel.speciesGroups.first(
      where: { $0.id==id }) {
      log.error("getGroup= \(matchingItem)")
      return matchingItem.name
    }
    log.error("getGroup: NIL")
    return nil
  }

  func version() -> String {
    guard let dictionary = Bundle.main.infoDictionary,
          let version = dictionary["CFBundleShortVersionString"] as? String,
          let build = dictionary["CFBundleVersion"] as? String else {
      return "Version information not available"
    }
    return "Version \(version) build \(build)"
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    // Setting up the environment objects for the preview
    SettingsView()
      .environmentObject(Settings())
  }
}

//deze SpeciesGroupPickerView hier in een ander bestand gaan zetten en meer globaal maken
struct SpeciesGroupPickerView: View {
  let log = SwiftyBeaver.self
//  @EnvironmentObject var speciesViewModel: SpeciesViewModel

  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
  @EnvironmentObject var regionsViewModel: RegionsViewModel
  @EnvironmentObject var regionListViewModel: RegionListViewModel
  @EnvironmentObject var settings: Settings

  @Binding var currentSpeciesGroup: Int?

  var entity: EntityType

  var body: some View {
    Section(header: Text(species)) {
      Picker(group, selection: $currentSpeciesGroup) { //??
        ForEach( entity != .species ? speciesGroupsViewModel.speciesGroupsAll : speciesGroupsViewModel.speciesGroups, id: \ .id) { speciesGroup in
          Text("\(speciesGroup.name)") //??> picture svg
            .tag(speciesGroup.id)
            .lineLimit(1)
            .truncationMode(.tail)
        }
      }
      .pickerStyle(.navigationLink)
      .onChange(of: currentSpeciesGroup) {
        log.error("2")
        log.error("Selected Group ID: \(String(describing: currentSpeciesGroup))")

        settings.selectedRegionListId = regionListViewModel.getId(
          region: settings.selectedRegionId,
          speciesGroup: currentSpeciesGroup ?? 0)

        if let selectedGroup = speciesGroupsViewModel.speciesGroupsByRegion.first(where: { $0.id == settings.selectedSpeciesGroup }) {
          settings.selectedSpeciesGroupName = selectedGroup.name
        }

        log.error("3")
        log.error("Region List ID: \(settings.selectedRegionListId), Region ID: \(settings.selectedRegionId), Species Group ID: \(String(describing: settings.selectedSpeciesGroup))")

        //speciesViewModel.fetchDataFirst(settings: settings)//??XXX
        //speciesViewModel.fetchDataSecondLanguage(settings: settings)

      }
    }
  }
}

struct RadiusPickerView: View {
  @Binding var selectedRadius: Int // Binding for Int radius selection

  let radiusOptions = Array(stride(from: 1000, through: 10000, by: 1000)) // Int values

  var body: some View {
    VStack {
      Picker(radius, selection: $selectedRadius) {
        ForEach(radiusOptions, id: \.self) { radius in
          Text("\(Int(radius)) m").tag(radius) // Convert to Int for display
        }
      }
      .pickerStyle(.menu) // Wheel picker style
    }
  }
}
