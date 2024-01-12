//
//  MapObservationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapObservationView: View {
    @StateObject private var observationsViewModel = ObservationsViewModel()
    
    @State private var selectedDate = Date()
    @EnvironmentObject var settings: Settings
    
    @State private var position : MapCameraPosition = .userLocation(fallback: .automatic)
    
//    let longitude = 4.606014
//    let latitude = 52.456955
    
    let longitude = 4.540332
    let latitude = 52.459402
    
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    ForEach(observationsViewModel.locations()) { location in
                        Marker(location.name, systemImage: "bird.fill", coordinate: location.coordinate)
                            .tint(.green)
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .onMapCameraChange { context in
                    print(context.region)
                }
                .mapControls() {
                    MapUserLocationButton()
                    MapPitchToggle()
                }
            }
            
            DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                .onChange(of: selectedDate) { newDate in
                    // Perform your action when the date changes
                    let currentLocation = CLLocationManager().location
                    observationsViewModel.fetchData(days: settings.days, endDate: selectedDate,
                                                    lat: currentLocation?.coordinate.latitude ?? latitude,
                                                    long: currentLocation?.coordinate.longitude ?? longitude,
                                                    radius: settings.radius)
                }
                .padding()
        }
        .onAppear(){
            let currentLocation = CLLocationManager().location
            observationsViewModel.fetchData(days: settings.days, endDate: selectedDate,
                                            lat: currentLocation?.coordinate.latitude ?? latitude,
                                            long: currentLocation?.coordinate.longitude ?? longitude,
                                            radius: settings.radius)
//            observationsViewModel.fetchData(days: 14, endDate: Date()+14, lat: 52.024052, long: 5.245350, radius: 1500)
        }
    }
}

#Preview {
    MapObservationView()
}
