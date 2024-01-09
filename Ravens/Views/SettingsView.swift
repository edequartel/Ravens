//
//  SettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SpeciesGroupViewModel()
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        
        NavigationStack {
            Form {
                Picker("Group:", selection: $settings.selectedSpeciesGroup) {
                    ForEach(viewModel.speciesGroups, id:\.id) { speciesGroup in
                        HStack() {
                            Text("\(speciesGroup.id) - \(speciesGroup.name)")
                        }
                    }
                }
                
                
                
                
            }
            .navigationTitle("Settings")
        }
        .onAppear(){
            viewModel.fetchData()
        }
    }
}

#Preview {
    SettingsView()
}
