//
//  settingsDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/01/2024.
//

import SwiftUI

struct SettingsDetailsView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupsViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    
    var count: Int = 0
    var results: Int = 0
    var showInfinity: Bool = true
    
    var body: some View {
        VStack() {
            VStack {
                HStack {
                    Text(settings.locationName)
                        .bold()
               }
            }
            .padding(.horizontal,10)

        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(settings.locationName) \(settings.selectedSpeciesGroupName) \(results)x \(14)d \(settings.selectedDate, formatter: dateFormatter)")
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
//        .environmentObject(SpeciesGroupViewModel(settings: Settings())
        .environmentObject(KeychainViewModel())
}
