//
//  FlipRadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 20/04/2024.
//

import SwiftUI

struct FlipRadiusView: View {
    
    @State private var isMapViewPresented = true
    
    var body: some View {
        ZStack() {
            if isMapViewPresented {
                MapObservationView()
            } else {
                ObservationsView(isShowing: $isMapViewPresented) //?? isToggleOn verwijderen!!
            }
            CircleButton(isToggleOn: $isMapViewPresented)
                .topLeft()
        }
    }
}

#Preview {
    FlipRadiusView()
}
