//
//  MapObservationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var position : MapCameraPosition = .userLocation(fallback: .automatic)
    //    @State private var position : MapCameraPosition = .automatic
    @State private var circlePos = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    if (settings.poiOn) {
                        ForEach(observationsViewModel.poiLocations) { location in
                            Marker(location.name, systemImage: "mappin", coordinate: location.coordinate)
                                .tint(.gray)
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
                
                .mapControls() {
                    MapUserLocationButton()
                    MapPitchToggle()
                    MapCompass() //tapping this makes it north
                }
                
                .safeAreaInset(edge: .bottom) {
                    SettingsDetailsView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                .onTapGesture { position in //get all the data from the location
                    if let coordinate = proxy.convert(position, from: .local) {
                        observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                                        lat: coordinate.latitude,
                                                        long: coordinate.longitude,
                                                        radius: settings.radius,
                                                        species_group: settings.selectedGroupId,
                                                        min_rarity: settings.selectedRarity)
                        
                        // Create a new CLLocation instance with the updated coordinates
                        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        circlePos = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                        // Update currentLocation with the new CLLocation instance
                        settings.currentLocation = newLocation
                    }
                }
            }
        }
        .onAppear(){
            // Get the actual location... not from settings
            let location: CLLocation? = CLLocationManager().location
            circlePos.latitude = location?.coordinate.latitude ?? latitude
            circlePos.longitude = location?.coordinate.latitude ?? longitude
            
            settings.currentLocation = location
            
            // Get the locations of all the observations... not from settings
            observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                            //                                            lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                            //                                            long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                            lat: circlePos.latitude,
                                            long: circlePos.longitude,
                                            radius: settings.radius,
                                            species_group: settings.selectedGroupId,
                                            min_rarity: settings.selectedRarity)
        }
    }
}

struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationView()
            .environmentObject(ObservationsViewModel())
            .environmentObject(Settings())
    }
}
