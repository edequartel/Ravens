//
//  RegionsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct RegionsView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject private var regionsViewModel: RegionsViewModel
  @EnvironmentObject private var regionListViewModel: RegionListViewModel

  @EnvironmentObject var settings: Settings

  var body: some View {
    Picker("Region", selection: $settings.selectedRegionId) {
      ForEach(regionsViewModel.regions, id: \.id) { region in
        HStack {
          //          Text("\(region.id)").tag(region.id)
          Text("\(region.name)").tag(region.name)
//          Text("\(region.type)")
        }
      }
    }
    .pickerStyle(.navigationLink)
    .onChange(of: settings.selectedRegionId) {

      print("settings.selectedRegionId \(settings.selectedRegionId)")
      print("settings.selectedSpeciesGroup \(settings.selectedSpeciesGroup ?? 1)")

      settings.regionListId = regionListViewModel.getId(
        region: settings.selectedRegionId,
        speciesGroup: settings.selectedSpeciesGroup ?? 1) ?? 5001
      print("settings.regionListId \(settings.regionListId)")

      settings.selectedSpeciesGroup = 1
    }
  }
}

struct RegionListView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject private var regionListViewModel: RegionListViewModel
  @EnvironmentObject var settings: Settings

  var body: some View {
    Picker("RegionList", selection: $settings.selectedRegionListIdStored) {
      ForEach(regionListViewModel.regionLists.sorted {
        $0.region != $1.region ? $0.region < $1.region : $0.speciesGroup < $1.speciesGroup
      }, id: \.id) { regionList in
        HStack {
          Text("\(regionList.region)")
          Text("\(regionList.speciesGroup)")
          Text(": \(regionList.id)")
        }
      }
    }
    .pickerStyle(.navigationLink)
    //      .onChange(of: settings.selectedRegionListIdStored) {
    //        print("xxxxxx")
    //      }
  }
}

struct RegionsView_Previews: PreviewProvider {
  static var previews: some View {
    RegionsView()
      .environmentObject(Settings())
  }
}
