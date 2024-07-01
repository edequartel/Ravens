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
    
    @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
    
    @EnvironmentObject var settings: Settings
    
    private var speciesGroups = [SpeciesGroup]()

    var body: some View {
        Picker("Region", selection: $settings.selectedRegionId) {
            ForEach(regionsViewModel.regions, id: \.id) { region in
                Text("\(region.name)").tag(region.id)
            }
        }
        .pickerStyle(.navigationLink)
        .onChange(of: settings.selectedRegionId) {
            // get the copy of speciesGroupsViewModel.speciesGroups
            speciesGroupsViewModel.speciesGroupsByRegion = speciesGroupsViewModel.speciesGroups
            // see which are not present in the selectedregion and prepare to remove
            var indicesToRemove = [Int]()

            for i in 0..<speciesGroupsViewModel.speciesGroupsByRegion.count {
                if regionListViewModel.getId(region: settings.selectedRegionId, species_group: speciesGroupsViewModel.speciesGroups[i].id) == -1 {
                    indicesToRemove.append(speciesGroupsViewModel.speciesGroups[i].id)
                }
            }            
            // remove them so the are edited in the picker
            for index in indicesToRemove {
                speciesGroupsViewModel.speciesGroupsByRegion.removeAll { speciesGroup in
                    speciesGroup.id == index
                }
            }
            // and set the selectedSpeciesGroupId to the first one at the start
            settings.selectedSpeciesGroupId = speciesGroupsViewModel.speciesGroupsByRegion[0].id
            print(">>selectedSpeciesGroupId: \(settings.selectedSpeciesGroupId)")
            
            // and save this
            settings.selectedRegionListId = regionListViewModel.getId(
                region: settings.selectedRegionId,
                species_group: settings.selectedSpeciesGroupId)
            print(">>selectedRegionListId: \(settings.selectedRegionListId)")
        }
    }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
            .environmentObject(Settings())
    }
}
