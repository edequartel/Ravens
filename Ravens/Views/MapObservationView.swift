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
    @State private var circlePos = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    if (settings.poiOn) {
                        ForEach(observationsViewModel.poiLocations) { location in
                            Marker(location.name, systemImage: "mappin", coordinate: location.coordinate)
                                .tint(.blue)
                        }
                    }
                    
                    ForEach(observationsViewModel.locations) { location in
                        Marker(location.name, systemImage: "bird.fill", coordinate: location.coordinate)
                            .tint(Color(myColor(value: location.rarity)))
                    }
                    
                    MapCircle(center: circlePos, radius: CLLocationDistance(settings.radius))
                        .foregroundStyle(.clear.opacity(100))
                        .stroke(.white, lineWidth: 1)
                }
                .mapStyle(.hybrid(elevation: .realistic))
                
                
                
                .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                                                lat: coordinate.latitude,
                                                                long: coordinate.longitude,
                                                                radius: settings.radius,
                                                                species_group: settings.selectedGroupId)
                                
                                // Create a new CLLocation instance with the updated coordinates
                                let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                circlePos = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
            //
            circlePos.latitude = settings.currentLocation?.coordinate.latitude ?? latitude
            circlePos.longitude = settings.currentLocation?.coordinate.longitude ?? longitude
            // Get the current locations of all the observations
            observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                            lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                            long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                            radius: settings.radius,
                                            species_group: settings.selectedGroupId)
        }
    }
}

struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsViewModel = ObservationsViewModel()
        let settings = Settings()

        // Setting up the environment objects for the preview
        MapObservationView()
            .environmentObject(observationsViewModel)
            .environmentObject(settings)
    }
}
