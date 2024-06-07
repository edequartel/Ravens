//
//  RadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct RadiusView: View {
    @State private var showFirstView = true
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            VStack {
                if showFirstView {
                    MapObservationView()
                } else {
                    ObservationsView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showFirstView.toggle()
                    }) {
                        Image(systemName: "rectangle.2.swap") 
                    }
                }
            }
            .navigationTitle(settings.selectedSpeciesGroupName)
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .onAppearOnce {
            showFirstView = settings.mapPreference
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    RadiusView()
}
