//
//  LanguagesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

struct LanguageView: View {
    @ObservedObject var viewModel = LanguageViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if let language = viewModel.language {
                    ForEach(language.results, id: \.code) { result in
                        VStack(alignment: .leading) {
                            Text("code".localized()+"\(result.code)")
                            Text("english".localized()+"\(result.name_en)")
                            Text("native".localized()+"\(result.name_native)")
                        }
                    }
                } else {
                    Text("languagedataisnil".localized())
                }
                
            }
            .navigationBarTitle("languages".localized())
        }
    }
}


#Preview {
    LanguageView()
}
