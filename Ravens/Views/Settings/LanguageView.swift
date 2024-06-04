//
//  LanguagesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct LanguageView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject private var languagesViewModel: LanguagesViewModel
    @EnvironmentObject private var speciesGroupsViewModel: SpeciesGroupsViewModel
    
    @EnvironmentObject private var regionsViewModel: RegionsViewModel
    @EnvironmentObject private var regionListViewModel: RegionListViewModel
    
    // State variable to hold the selected option
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var speciesViewModel: SpeciesViewModel

    var body: some View {
//        Button("details") {
//            print("> selectedRegionListId \(settings.selectedRegionListId) selectedRegionId \(settings.selectedRegionId) selectedSpeciesGroupId \(settings.selectedSpeciesGroupId)")
//        }

//        VStack {
            
            Picker("Language", selection: $settings.selectedLanguage) {
                ForEach(languagesViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.name_native).tag(language.code)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: settings.selectedLanguage) {
                speciesGroupsViewModel.fetchData(language: settings.selectedLanguage)
                regionsViewModel.fetchData(language: settings.selectedLanguage)
                //deze variable opslaan bij wijzigingen in region and species group settings
                //als stored variabele later gebruiken bij opstarten
                //en als published zodat de gewijzigd wordt en gelijk gebuikt
                print("selectedRegionListId: \(settings.selectedRegionListId)")
                speciesViewModel.fetchDataFirst(language: settings.selectedLanguage, for: settings.selectedRegionListId)
            }
            

            
            Picker("Second language", selection: $settings.selectedSecondLanguage) {
                ForEach(languagesViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.name_native).tag(language.code)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: settings.selectedSecondLanguage) {
                print("selectedRegionListId: \(settings.selectedRegionListId)")
                speciesViewModel.fetchDataSecondLanguage(language: settings.selectedSecondLanguage, for: settings.selectedRegionListId)
            }
//        }
    }
}

#Preview {
    LanguageView()
        .environmentObject(Settings())
}



