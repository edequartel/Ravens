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
                        Text("Total \(observationsViewModel.observations?.results.count ?? 0) /")
                        Text("Shown \(observationsViewModel.observations?.count ?? 0)")
                        Spacer()
                    }
                }
                
                Section("List") {
                    List {
                        if let results = observationsViewModel.observations?.results {
                            
                            ForEach(results.sorted(by: {$0.rarity > $1.rarity} ), id: \.id) { result in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(Color(myColor(value: result.rarity)))
                                        
                                        Text("\(result.species_detail.name)")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        Text("\(result.user)")
                                            .font(.subheadline)
                                    }
                                }
                                .onTapGesture {
                                    if let url = URL(string: result.permalink) {
                                        UIApplication.shared.open(url)
                                    }
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

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsViewModel = ObservationsViewModel()
        let settings = Settings()
        
        // Setting up the environment objects for the preview
        ObservationsView()
            .environmentObject(observationsViewModel)
            .environmentObject(settings)
    }
}
