//
//  FlipLocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 21/04/2024.
//

import SwiftUI

struct FlipLocationView: View {
    
    @EnvironmentObject var settings: Settings
    
    @State private var isMapViewPresented = true
    
    var body: some View {
        ZStack() {
            if isMapViewPresented {
                MapObservationsLocationView()
            } else {
                ObservationsLocationView(
                    locationId: settings.locationId,
                    locationStr: settings.locationStr
                )
            }
            CircleButton(isToggleOn: $isMapViewPresented)
                .topLeft()
        }
    }
}

#Preview {
    FlipLocationView()
}

