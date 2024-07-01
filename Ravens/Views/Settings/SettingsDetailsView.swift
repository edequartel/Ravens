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
                    Spacer()
                    
                }
                HStack {
                    //                NetworkView()
                    Image(systemName: "binoculars.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(RarityColor(value: settings.selectedRarity), .white)
                    Text(settings.selectedSpeciesGroupName)
                        .lineLimit(1)
                    if (settings.infinity && showInfinity) {
                        HStack {
                            Image(systemName: "infinity")
                            Spacer()
                        }
                    } else {
                        Spacer()
                        Text("\(results)x")
                        
                        Text("\(settings.days)d")
                        Text("\(settings.selectedDate, formatter: dateFormatter)")
                    }
                    
                    
                }
            }
            .padding(.horizontal,10)
            .font(.footnote)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(settings.locationName) \(settings.selectedSpeciesGroupName) \(results)x \(settings.days)d \(settings.selectedDate, formatter: dateFormatter)")
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
