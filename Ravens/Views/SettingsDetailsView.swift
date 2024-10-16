//
//  settingsDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/01/2024.
//

import SwiftUI

struct SettingsDetailsView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    
    var count: Int = 0
    var results: Int = 0
    var showInfinity: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .obsGreenFlower)
//            Spacer()
            NetworkView()
            Spacer()
//            Text("\(settings.selectedLanguage)")
//            Text("\(count)/\(results)x")
            Text("\(results)x")
            Image(systemName: "binoculars.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(myColor(value: settings.selectedRarity), .white)
            Text("\(speciesGroupViewModel.getName(forID: settings.selectedSpeciesGroup) ?? "unknown")")
                .lineLimit(1)
            
            if (settings.infinity && showInfinity) {
                Image(systemName: "infinity")
            } else {
                Text("\(settings.days)d")
                Text("\(settings.selectedDate, formatter: dateFormatter)")
            }
            
            
        }
        .bold()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE dd-MM"
        return formatter
    }
}

#Preview {
    SettingsDetailsView()
        .environmentObject(Settings())
        .environmentObject(SpeciesGroupViewModel(settings: Settings()))
        .environmentObject(KeychainViewModel())
}
