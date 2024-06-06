//
//  LocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct LocationView: View {
    @State private var showFirstView = true
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var areasViewModel: AreasViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if showFirstView {
                    MapObservationsLocationView()
                } else {
                    ObservationsLocationView()
                }
            }
            .navigationTitle("\(settings.locationName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showFirstView.toggle()
                    }) {
                        Image(systemName: "rectangle.2.swap")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if areasViewModel.isIDInRecords(areaID: settings.locationId) {
                            areasViewModel.removeRecord(areaID: settings.locationId)
                        } else {
                            areasViewModel.appendRecord(areaName: settings.locationName, areaID: settings.locationId)
                        }
                    }) {
                        Image(systemName: areasViewModel.isIDInRecords(areaID: settings.locationId) ? "pentagon.fill" : "pentagon")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AreasView()) {
                        Label("Areas", systemImage: "list.bullet")
                    }
                }
            }
            .onAppearOnce {
                showFirstView = settings.mapPreference
            }
        }
    }
}

#Preview {
    LocationView()
}

