//
//  MapObservationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import MapKit


struct MapObservationView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var position : MapCameraPosition = .userLocation(fallback: .automatic)
  
//    @State private var position = MapCameraPosition.region(
//        MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 52.023861, longitude: 5.243376),
//            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        )
//    )
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    
//                    MapCircle(center: .position, radius: CLLocationDistance(250))
//                    Marker("Me", systemImage: "mappin", coordinate: coordinate)
                    
                    if (settings.poiOn) {
                        ForEach(observationsViewModel.poiLocations) { location in
                            Marker(location.name, systemImage: "mappin", coordinate: location.coordinate)
                                .tint(.blue)
                        }
                    }
                    
                    
                    ForEach(observationsViewModel.locations) { location in
                        Marker(location.name, systemImage: "bird.fill", coordinate: location.coordinate)
                            .tint(.green)
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))
//                .onMapCameraChange { context in
//                    print(context.region)
//                }
                
                
                .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                                                lat: coordinate.latitude,
                                                                long: coordinate.longitude,
                                                                radius: settings.radius,
                                                                species_group: settings.selectedGroupId)
                                
                                // Create a new CLLocation instance with the updated coordinates
                                let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                // Update currentLocation with the new CLLocation instance
                                settings.currentLocation = newLocation
                            }
                        }
                
                .mapControls() {
                    MapUserLocationButton()
                    MapPitchToggle()
                }
            }
            
            HStack {
                Text("\(settings.selectedGroupString)")
                    .lineLimit(1) 
                    .truncationMode(.tail)
                Spacer()
                DatePicker("", selection: $settings.selectedDate, displayedComponents: [.date])
                    .onChange(of: settings.selectedDate) {
                        // Perform your action when the date changes
                        observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                                        lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                                        long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                                        radius: settings.radius,
                                                        species_group: settings.selectedGroupId)
                    }
            }
            .padding()
                
        }
        .onAppear(){
            print("radius \(settings.radius)")
            print("days \(settings.days)")
            // Get the current locations of all the observations
            observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                            lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                            long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                            radius: settings.radius,
                                            species_group: settings.selectedGroupId)
        }
    }
}

#Preview {
    MapObservationView()
}
