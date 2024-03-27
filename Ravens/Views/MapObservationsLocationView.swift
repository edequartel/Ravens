//
//  MapObservationsLocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 26/03/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver


struct MapObservationsLocationView: View {
    let log = SwiftyBeaver.self
    
    @StateObject private var locationIdViewModel = LocationIdViewModel()
   
    @StateObject private var geoJSONViewModel = GeoJSONViewModel()
    @State private var polyOverlays = [MKPolygon]()
    
    @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    
    @ObservedObject var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition?
    
    @State private var locationId: Int = 0
    @Binding var sharedLocationId: Int
    
    @State private var deltaLat: Double = 0.1
    @State private var deltaLong: Double = 0.1
    
    
    @State private var MapCameraPositiondefault = MapCameraPosition
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
    
    // New computed property
    var cameraBinding: Binding<MapCameraPosition> {
        Binding<MapCameraPosition>(
            get: { self.cameraPosition ?? self.MapCameraPositiondefault },
            set: { self.cameraPosition = $0 }
        )
    }
    
    @State private var circlePos: CLLocationCoordinate2D?
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: cameraBinding) {
                    
                    UserAnnotation()
                    
                    if (settings.poiOn) {
                        ForEach(observationsViewModel.poiLocations) { location in
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
                    
                    // location observation
                    ForEach(observationsLocationViewModel.locations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            Circle()
                                .fill(Color(myColor(value: location.rarity)))
                                .stroke(location.hasSound ? Color.white : Color.clear,lineWidth: 1)
                                .frame(width: 12, height: 12)
                            
                                .overlay(
                                    Circle()
                                        .fill(location.hasPhoto ? Color.white : Color.clear)
                                        .frame(width: 6, height: 6)
                                )
                        }
                    }
                    
                    //JSONData
                    ForEach(polyOverlays, id: \.self) { polyOverlay in
                        MapPolygon(polyOverlay)
                            .stroke(.pink, lineWidth: 1)
                            .foregroundStyle(.blue.opacity(0.1))
                    }
                    
                    
                }
                .mapStyle(settings.mapStyle)
                
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        SettingsDetailsView(count: observationsViewModel.locations.count, results: observationsViewModel.observations?.count ?? 0 )

                        if locationIdViewModel.locations.count > 0 {
                            HStack {
                                Text("\(locationIdViewModel.locations[0].name)")
                                Spacer()
                                Text("\(locationIdViewModel.locations[0].id)")
                                
                            }
                            .foregroundColor(.white)
                        } else {
                            Text("Default Name")
                        }
                        
                    }
                }
                
                .onTapGesture() { position in
                    
                    if let coordinate = proxy.convert(position, from: .local) {
                        
                        // Create a new CLLocation instance with the updated coordinates
                        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        circlePos = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                       
                        //lat,long -> locationId -> geoJSON
                        polyOverlays.removeAll()
                        locationIdViewModel.fetchLocations(latitude: coordinate.latitude, longitude: coordinate.longitude) { fetchedLocations in
                            // Use fetchedLocations here, er is er echter altijd maar 1 daarom pakken we de eerste
                            for location in fetchedLocations {
                                print(location.id) //dit is de locatieId en hiermee halen we de geoJSON data op
                                geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
                                    polyOverlays = polyOverlaysIn
                    
                                    locationId = location.id
                                    sharedLocationId = location.id
                                    
                                    //and now er get the observations from the locationId
                                    observationsLocationViewModel.fetchData(locationId:  locationId, limit: 100, offset: 0, completion: {
                                        print("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                        print(observationsLocationViewModel.span)
                                        cameraPosition = MapCameraPosition
                                            .region(
                                                MKCoordinateRegion(
                                                    center: CLLocationCoordinate2D(
                                                        latitude: observationsLocationViewModel.span.latitude,
                                                        longitude: observationsLocationViewModel.span.longitude),
                                                    
                                                    span: MKCoordinateSpan(
                                                        latitudeDelta: observationsLocationViewModel.span.latitudeDelta,
                                                        longitudeDelta: observationsLocationViewModel.span.longitudeDelta)
                                                )
                                            )
                                    }
                                    )
                                }
                            }
                        }
                    
                        // Update currentLocation with the new CLLocation instance
                        settings.currentLocation = newLocation
                    }
                }
                .mapControls() {
                    MapCompass() //tapping this makes it north
                    
                }
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let location = self.locationManager.location {
                    let myLatitude = location.coordinate.latitude
                    let myLongitude = location.coordinate.longitude
                    print("My location is: \(myLatitude), \(myLongitude)")
                    circlePos = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    
                    // save the location
                    settings.currentLocation = location
                    
                    // geoJSON
                    polyOverlays.removeAll()
                    
                    locationIdViewModel.fetchLocations(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { fetchedLocations in
                        // Use fetchedLocations here
                        
                        for location in fetchedLocations {
                            geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
                                polyOverlays = polyOverlaysIn
                                locationId = location.id
                                sharedLocationId = location.id
                                observationsLocationViewModel.fetchData(locationId: locationId, limit: 100, offset: 0, completion: { 
                                    print("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                    print(observationsLocationViewModel.span)
                                    cameraPosition = MapCameraPosition
                                        .region(
                                            MKCoordinateRegion(
//                                                center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude),
                                                center: CLLocationCoordinate2D(
                                                    latitude: observationsLocationViewModel.span.latitude,
                                                    longitude: observationsLocationViewModel.span.longitude),
                                                
                                                span: MKCoordinateSpan(
                                                    latitudeDelta: observationsLocationViewModel.span.latitudeDelta,
                                                    longitudeDelta: observationsLocationViewModel.span.longitudeDelta)
                                            )
                                        )
                                }
                                )
                
                            }
                        }
                    }
                    
                    // Initialize cameraPosition with user's current location
//                    cameraPosition = MapCameraPosition
//                        .region(
//                            MKCoordinateRegion(
//                                center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude),
//                                span: MKCoordinateSpan(latitudeDelta: 0.012277993560553035, longitudeDelta: 0.005419711169082575)
//                            )
//                        )
                    
                    
                    
                    
                } else {
                    print("Location is not available yet")
                    // Handle the case when location is not available
                }
                
                log.verbose("settings.selectedGroupId:  \(settings.selectedGroup)")
                speciesGroupViewModel.fetchData(language: settings.selectedLanguage, completion: { _ in log.info("fetcheddata speciesGroupViewModel") })
            }
        }
    }
    
    
    func colorByMapStyle() -> Color {
        if settings.mapStyleChoice == .standard {
            return Color.gray
        } else {
            return Color.white
        }
    }
}


struct MapObservationLocationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationsLocationView(sharedLocationId: .constant(0))
            .environmentObject(Settings())
            .environmentObject(ObservationsViewModel(settings: Settings()))
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
            .environmentObject(KeychainViewModel())
        
    }
}
