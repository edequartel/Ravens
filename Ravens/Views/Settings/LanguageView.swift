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
    @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel
    
    var body: some View {
        VStack {
            Picker("Language", selection: $settings.selectedLanguage) {
                ForEach(languagesViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.name_native).tag(language.code)
                }
            }
            .onChange(of: settings.selectedLanguage) {
                speciesGroupsViewModel.fetchData(language: settings.selectedLanguage)
                regionsViewModel.fetchData(language: settings.selectedLanguage)
                //deze variable opslaan bij wijzigingen in region and species group settings
                //als stored variabele later gebruiken bij opstarten
                //en als published zodat de gewijzigd wordt en gelijk gebuikt
                
                print("settings.selectedSpeciesGroup \(settings.selectedSpeciesGroup)")
                print("settings.selectedRegionListId \(settings.selectedRegionListId)")
                let id = regionListViewModel.getId(region: settings.selectedRegionId, species_group: settings.selectedSpeciesGroup)
                print("id \(id)")
                //
                speciesViewModel.fetchData(language: settings.selectedLanguage, for: id)
                
            }
            
//            Picker("Second language", selection: $settings.selectedSecondLanguage) {
//                ForEach(languagesViewModel.language?.results ?? [], id: \.self) { language in
//                    Text(language.name_native).tag(language.code)
//                }
//            }
//            .onChange(of: settings.selectedSecondLanguage) {
//                speciesSecondLangViewModel.fetchData(language: settings.selectedSecondLanguage, for: settings.selectedSpeciesGroup) 
//            }
            
        }
    }
}

#Preview {
    LanguageView()
        .environmentObject(Settings())
}



