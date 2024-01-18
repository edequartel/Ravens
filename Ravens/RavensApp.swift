//
//  RavensApp.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

@main
struct RavensApp: App {
    @StateObject private var settings = Settings()
    let observationsSpeciesViewModel = ObservationsSpeciesViewModel()
    let observationsModel =
    ObservationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(observationsSpeciesViewModel)
                .environmentObject(observationsModel)
        }
    }
}
