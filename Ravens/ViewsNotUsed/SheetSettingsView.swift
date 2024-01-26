//
//  SheetSettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 22/01/2024.
//

import SwiftUI

struct SheetSettingsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        HStack {
            Text("\(settings.selectedGroupString)")
                                .lineLimit(1)
                                .truncationMode(.tail)
            Spacer()
            Text("\(observationsViewModel.observations?.results.count ?? 0)/\(observationsViewModel.observations?.count ?? 0)")

            Spacer()
            DatePicker("", selection: $settings.selectedDate, displayedComponents: [.date])
                .onChange(of: settings.selectedDate) {
                    // Perform your action when the date changes
                    
                    observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                                    lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                                    long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                                    radius: settings.radius,
                                                    species_group: settings.selectedGroupId,
                                                    min_rarity: settings.selectedRarity)
                }
        }
        .padding()
    }
}

struct SheetSettings_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsViewModel = ObservationsViewModel()
        let settings = Settings()

        // Setting up the environment objects for the preview
        SheetSettingsView()
            .environmentObject(observationsViewModel)
            .environmentObject(settings)
    }
}
