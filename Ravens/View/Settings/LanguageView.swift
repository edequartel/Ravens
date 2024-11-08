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
            Picker("Language", selection: $settings.selectedLanguage) {
                ForEach(languagesViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.nameNative).tag(language.code)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: settings.selectedLanguage) {
                speciesGroupsViewModel.fetchData(settings: settings) 
                regionsViewModel.fetchData(settings: settings)
                //deze variable opslaan bij wijzigingen in region and species group settings
                //als stored variabele later gebruiken bij opstarten
                //en als published zodat de gewijzigd wordt en gelijk gebuikt
                print("selectedRegionListId: \(settings.selectedRegionListId)")
                speciesViewModel.fetchDataFirst(settings: settings)
            }
            

            
            Picker("Second language", selection: $settings.selectedSecondLanguage) {
                ForEach(languagesViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.nameNative).tag(language.code)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: settings.selectedSecondLanguage) {
                print("selectedRegionListId: \(settings.selectedRegionListId)")
                speciesViewModel.fetchDataSecondLanguage(settings: settings)
            }
//        }
    }
}

#Preview {
    LanguageView()
        .environmentObject(Settings())
}



