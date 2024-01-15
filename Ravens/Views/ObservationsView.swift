//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
import MapKit

struct ObservationsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    HStack {
                        Text("Obs:\(observationsViewModel.observations?.count ?? 0)")
                        Spacer()
                        Text("Shown:\(observationsViewModel.observations?.results.count ?? 0)")
                    }
                }
                
                Section("List") {
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
                        } else {
                            // Handle the case when observationsViewModel.observations?.results is nil
                            Text("No observations available")
                        }
                    }
                }
            }
        }
        .onAppear(){
            print("radius \(settings.radius)")
            print("days \(settings.days)")
            // Get the current locations of all the observations
//            settings.currentLocation = CLLocationManager().location
            observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                            lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                            long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                            radius: settings.radius,
                                            species_group: settings.selectedGroupId)
        }
    }
}

#Preview {
    ObservationsView()
}
