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
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var settings: Settings
    
//    @State private var myActualPosition : MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 6, longitudeDelta: 4)
        )
    )
    
    //    @State private var position : MapCameraPosition = .automatic
    @State private var circlePos = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    @State private var long = "longitude"
    @State private var lat = "latitude"
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    if (settings.poiOn) {
                        ForEach(observationsViewModel.poiLocations) { location in
//                            Marker(location.name, systemImage: "mappin", coordinate: location.coordinate)
//                                .tint(.gray)
                            
                            Annotation(location.name, coordinate: location.coordinate) {
                                Triangle()
                                    .fill(Color.gray)
                                    .frame(width: 5, height: 5)
                                    .overlay(
                                        Triangle()
                                            .stroke(Color.white, lineWidth: 1) // Customize the border color and width
                                    )
                            }
                            
                            
                        }
                    }
                    
                    ForEach(observationsViewModel.locations) { location in
//                        Marker(location.name, systemImage: "binoculars.fill", coordinate: location.coordinate)
//                            .tint(Color(myColor(value: location.rarity)))
                        
                        Annotation(location.name, coordinate: location.coordinate) {
                            Circle()
                                .fill(Color(myColor(value: location.rarity)))
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(location.hasPhoto ? Color.red : Color.white, lineWidth: 1) // Customize the border color and width
                                )
                        }
                        
                    }
                    
                    MapCircle(center: circlePos, radius: CLLocationDistance(settings.radius))
                        .foregroundStyle(.clear.opacity(100))
                        .stroke(.white, lineWidth: 1)
                    
//                    Marker("me", systemImahe: "mappin", coordinate: myActualPosition.camera?.centerCoordinate)
//                        .tint(.red)
                    
                    
                }
                .mapStyle(.hybrid(elevation: .realistic))
//                .mapStyle(.standard(elevation: .realistic))
                
                .mapControls() {
//                    MapUserLocationButton()
                    MapPitchToggle()
                    MapCompass() //tapping this makes it north
//                    Map...
                }
                
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        SettingsDetailsView(count: observationsViewModel.locations.count, results: observationsViewModel.observations?.count ?? 0 )
//                        HStack() {
//                            Text(long)
//                            Spacer()
//                            Text(lat)
//                        }
//                        .padding()
//                        .foregroundColor(.white)
                    }

                }

//                .onLongPressGesture(perform: {print("LONGPRESGESTURE")})
                
                .onTapGesture() { position in //get all the data from the location
                    if let coordinate = proxy.convert(position, from: .local) {
                        observationsViewModel.fetchData(lat: coordinate.latitude, long: coordinate.longitude)
                        lat =  String(coordinate.latitude)
                        long = String(coordinate.longitude)
                        
                        
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
            
            // Get the actual location
            let location: CLLocation? = CLLocationManager().location
            circlePos.latitude = location?.coordinate.latitude ?? latitude
            circlePos.longitude = location?.coordinate.latitude ?? longitude
            
            settings.currentLocation = location
            
            // Get the locations of all the observations... not from settings
            observationsViewModel.fetchData(lat: circlePos.latitude,
                                            long: circlePos.longitude)

            log.verbose("settings.selectedGroupId:  \(settings.selectedGroup)")
            speciesGroupViewModel.fetchData(completion: { log.info("fetcheddata speciesGroupViewModel") })
            
        }
    }
}

struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationView()
            .environmentObject(Settings())
            .environmentObject(ObservationsViewModel(settings: Settings()))
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))

    }
}
