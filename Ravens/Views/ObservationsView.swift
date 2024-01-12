//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
import MapKit

struct ObservationsView: View {
    @StateObject private var observationsViewModel = ObservationsViewModel()
    
    @EnvironmentObject var settings: Settings
    @State private var selectedDate = Date()
    
    let longitude = 4.540332
    let latitude = 52.459402
    
    var location = [Location]()
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                    .onChange(of: selectedDate) { newDate in
                        // Perform your action when the date changes
                        let currentLocation = CLLocationManager().location
                        observationsViewModel.fetchData(days: settings.days, endDate: Date(),
                                                        lat: currentLocation?.coordinate.latitude ?? latitude,
                                                        long: currentLocation?.coordinate.longitude ?? longitude,
                                                        radius: settings.radius)
                    }
                
                Section("List") {
                    Text("\(observationsViewModel.observations?.count ?? 0)")
                    Text("\(observationsViewModel.observations?.results.count ?? 0)")
                    List {
                        if let observations = observationsViewModel.observations?.results {
                            
                            ForEach(observations.indices, id: \.self) { index in
                                let result = observations[index]

                                VStack(alignment: .leading) {
                                    Text("\(index + 1). \(result.species_detail.name)")
                                        .font(.subheadline)
                                    Text("User: \(result.user)")
                                        .font(.subheadline)
                                }
                            }

                            
//                            ForEach(observations.sorted(by: { $0.species_detail.name < $1.species_detail.name }), id: \.id) { result in
//                                VStack(alignment: .leading) {
//                                    Text("\(result.species_detail.name)")
//                                        .font(.subheadline)
//                                    Text("User: \(result.user)")
//                                        .font(.subheadline)
//                                }
//                            }
                        } else {
                            // Handle the case when observationsViewModel.observations?.results is nil
                            Text("No observations available")
                        }
                    }
                }
            }
        }
        .onAppear(){
            let currentLocation = CLLocationManager().location
            observationsViewModel.fetchData(days: settings.days, endDate: Date(),
                                            lat: currentLocation?.coordinate.latitude ?? latitude,
                                            long: currentLocation?.coordinate.longitude ?? longitude,
                                            radius: settings.radius)
        }
    }
}

#Preview {
    ObservationsView()
}
