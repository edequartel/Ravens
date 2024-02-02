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
    @ObservedObject var viewModel = LanguageViewModel()
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Picker("Language", selection: $settings.selectedLanguage) {
            if let language = viewModel.language {
                ForEach(language.results, id: \.code) { language in
                    Text("\(language.code)")
//                    Text("English \(language.name_en)")
//                    Text("Native \(language.name_native)")
                }
            }
            else {
                Text("languagedataisnil")
            }
        }
        .onChange(of: settings.selectedRegion) {
            log.verbose("selectedRegion \(settings.selectedLanguage)")
        }
    }
}


#Preview {
    LanguageView()
}
