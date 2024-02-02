//
//  LanguagesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct LanguageView: View {
    // Define an array of strings
    let options = ["nl", "eng"]
    
    // State variable to hold the selected option
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack {
            Picker("Language", selection: $settings.selectedLanguage) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
        }
    }
}

#Preview {
    LanguageView()
}



