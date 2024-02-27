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
    
    var count: Int = 0
    var results: Int = 0
    
    var body: some View {
        HStack {
            Spacer()
//            Text("\(settings.selectedLanguage)")
            Text("\(count)/\(results)x")
            Image(systemName: "binoculars.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(myColor(value: settings.selectedRarity), .white)
            Text("\(speciesGroupViewModel.getName(forID: settings.selectedSpeciesGroup) ?? "unknown")")
            Text("\(settings.days)d")
            Text("\(settings.selectedDate, formatter: dateFormatter)")
        }
        .padding(5)
        .font(.headline)
        .foregroundColor(.obsGreenFlower)
        .background(Color.obsGreenEagle.opacity(0.5))
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
}
