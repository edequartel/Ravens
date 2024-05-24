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
    
    // State variable to hold the selected option
    @EnvironmentObject var settings: Settings
    
    @State private var language = ""
    
    var body: some View {
        VStack {
            Picker("Language", selection: $settings.selectedLanguage) {
                ForEach(languageViewModel.language?.results ?? [], id: \.self) { language in
                    Text(language.name_en).tag(language.code)
                }
            }
            .onChange(of: settings.selectedLanguage) {
                speciesGroupViewModel.fetchData(language: settings.selectedLanguage)
            }
        }
    }
}

#Preview {
    LanguageView()
        .environmentObject(Settings())
}



