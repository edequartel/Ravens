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
    @EnvironmentObject private var languageViewModel: LanguageViewModel
    @EnvironmentObject private var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject private var regionsViewModel: RegionsViewModel
    
    // State variable to hold the selected option
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel
    
    var body: some View {
        VStack {
            Picker("Language", selection: $settings.selectedLanguage) {
                ForEach(languageViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.name_native).tag(language.code)
                }
            }
            .onChange(of: settings.selectedLanguage) {
                //
                print("selectedGroup: \(settings.selectedGroup)")
                speciesGroupViewModel.fetchData(language: settings.selectedLanguage)
                regionsViewModel.fetchData(language: settings.selectedLanguage)
                
//                speciesViewModel.fetchData(language: settings.selectedLanguage, for: settings.selectedGroup)
//                speciesSecondLangViewModel.fetchData(language: settings.selectedLanguage, for: settings.selectedGroup)
                
            }
        }
    }
}

#Preview {
    LanguageView()
        .environmentObject(Settings())
}



