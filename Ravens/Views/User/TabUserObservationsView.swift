//
//  UserObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct TabUserObservationsView: View {
    @EnvironmentObject var settings: Settings
    @State private var showFirstView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if showFirstView && !settings.accessibility {
                    MapObservationsUserView()
                } else {
                    ObservationsUserView()
                }
            }
            .toolbar {
                if !settings.accessibility {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showFirstView.toggle()
                        }) {
                            Image(systemName: "rectangle.2.swap") // Replace with your desired image
                            //                        Text("\(settings.userName)")
                        }
                    }
                }
            }
            .navigationTitle("\(settings.userName)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppearOnce {
                showFirstView = settings.mapPreference
            }
        }
    }
}

#Preview {
    TabUserObservationsView()
}
