//
//  RadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct RadiusView: View {
    //    @EnvironmentObject var settings: Settings
    @State private var showFirstView = true
    
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
                        Image(systemName: "rectangle.2.swap") // Replace with your desired image
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    RadiusView()
}
