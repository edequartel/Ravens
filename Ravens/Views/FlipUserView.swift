//
//  FlipUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 22/04/2024.
//

import SwiftUI

struct FlipUserView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    
    @State private var isMapViewPresented = true
    
    var body: some View {
        ZStack() {
            if isMapViewPresented {
                MapObservationsUserView()
            } else {
                ObservationsUserViewExtra()
            }
            CircleButton(isToggleOn: $isMapViewPresented)
                .topLeft()
        }
    }
}

#Preview {
    FlipUserView()
}
