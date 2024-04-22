//
//  FlipSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 22/04/2024.
//

import SwiftUI

struct FlipSpeciesView: View {
    @EnvironmentObject var settings: Settings
    
    @State private var isMapViewPresented = true
    
    var speciesID: Int
    var speciesName: String
    
    var body: some View {
        ZStack() {
            if isMapViewPresented {
                MapObservationsSpeciesView(
                    speciesID: speciesID,
                    speciesName: speciesName
                )
            } else {
                ObservationsSpeciesView(
                    speciesID: speciesID,
                    speciesName: speciesName
                )
            }
            CircleButton(isToggleOn: $isMapViewPresented)
                .topLeft()
        }
    }
}

#Preview {
    FlipSpeciesView(speciesID: 0, speciesName: "NoName")
}

