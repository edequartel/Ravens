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
    
    @ObservedObject var viewModel = POIViewModel()
    @StateObject private var locationIdViewModel = LocationIdViewModel()
    
    @StateObject private var geoJSONViewModel = GeoJSONViewModel()
    @State private var polyOverlays = [MKPolygon]()
    
    @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    
    @ObservedObject var locationManager = LocationManager()
    
    @State private var cameraPosition: MapCameraPosition?
    @State private var isSheetObservationsLocationsViewPresented = false
    
    @State private var locationId: Int = 0
    @State private var locationStr: String = "no location"

    @State private var circlePos: CLLocationCoordinate2D?
    
    @State private var MapCameraPositiondefault = MapCameraPosition
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        )
    
    // New computed property
    var cameraBinding: Binding<MapCameraPosition> {
        Binding<MapCameraPosition>(
            get: { self.cameraPosition ?? self.MapCameraPositiondefault },
            set: { self.cameraPosition = $0 }
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                MapReader { proxy in
                    Map(position: cameraBinding) {
                        
                        UserAnnotation()
                        
                        if (settings.poiOn) {
                            ForEach(viewModel.poiList, id: \.name) { poi in
                                Annotation(poi.name, coordinate: poi.coordinate.cllocationCoordinate) {
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
//                            HStack {
                                SettingsDetailsView(count: observationsLocationViewModel.locations.count, results: observationsLocationViewModel.observations?.count ?? 0)
//                            }
//                            .padding(5)
//                            .frame(maxHeight: 30)
                            
                            HStack {
                                Spacer()
                                let text = locationIdViewModel.locations.count > 0 ? "\(locationIdViewModel.locations[0].name)" : "Default Name"
                                Text(text)
                                    .frame(height: 30)
                            }
//                            .padding(5)
                            .font(.headline)

                            .frame(height: 30)
                            .foregroundColor(.obsGreenFlower)
                            .background(Color.obsGreenEagle.opacity(0.5))
                            
                            
                            //
                            HStack {
                                Spacer()
                                Button(action: {
                                    if let newDate = Calendar.current.date(byAdding: .day, value: -settings.days, to: settings.selectedDate) {
                                        settings.selectedDate = min(newDate, Date())
                                    }
                                    print("==============================>\(settings.selectedDate)")
                                    
                                    // Debugging or additional actions
//                                    locationIdViewModel.fetchData(limit: 100, date: settings.selectedDate, days: settings.days)
                                    observationsLocationViewModel.fetchData(locationId:  locationId, limit: 100, offset: 0, settings: settings, completion: {
                                        log.info("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                        log.info(observationsLocationViewModel.span)
                                    } )
                                    
                                    
                                }) {
                                    Image(systemName: "backward.fill")
                                }
                                
                                Button(action: {
                                    // Calculate the potential new date by adding days to the selected date
                                    if let newDate = Calendar.current.date(byAdding: .day, value: settings.days, to: settings.selectedDate) {
                                        // Ensure the new date does not go beyond today
                                        settings.selectedDate = min(newDate, Date())
                                    }
                                    // Debugging or additional actions
                                    observationsLocationViewModel.fetchData(locationId:  locationId, limit: 100, offset: 0, settings: settings, completion: {
                                        log.info("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                        log.info(observationsLocationViewModel.span)
                                    } )
                                    
                                    
                                    
                                }) {
                                    Image(systemName: "forward.fill")
                                }
                                
                                Button(action: {
                                    settings.selectedDate = Date()
                                    log.info("Date updated to \(settings.selectedDate)")
                                    
                                    observationsLocationViewModel.fetchData(locationId:  locationId, limit: 100, offset: 0, settings: settings, completion: {
                                        log.info("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                        log.info(observationsLocationViewModel.span)
                                    } )
                                }) {
                                    Image(systemName: "square.fill")
                                }
                                
                                
                            }
                            .padding(5)
                            .frame(maxHeight: 30)
                            .foregroundColor(.obsGreenFlower)
                            .background(Color.obsGreenEagle.opacity(0.5))

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
                                    log.info(location.id) //dit is de locatieId en hiermee halen we de geoJSON data op
                                    geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
                                        polyOverlays = polyOverlaysIn
                                        locationId = location.id
                                        
//                                        log.error("\(locationIdViewModel.count)")
                                        
                                        //and now er get the observations from the locationId
                                        observationsLocationViewModel.fetchData(locationId:  locationId, limit: 100, offset: 0, settings: settings, completion: {
                                            log.info("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                            log.info(observationsLocationViewModel.span)
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
            ObservationCircle(toggle: $isSheetObservationsLocationsViewPresented, colorHex: "a7b731")
            
        }
        
        .sheet(isPresented: $isSheetObservationsLocationsViewPresented) {
            ObservationsLocationView(
                locationId: locationId,
                locationStr: locationStr,
                isShowing: $isSheetObservationsLocationsViewPresented)
        }
        
        
        
        .onAppear() {
        //onappear
            viewModel.fetchPOIs()
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    //get the location
                    if settings.isFirstAppear {
                        if let location = self.locationManager.location {
                            log.info("get the location at onAppear in MapObservationLocationView")
                            circlePos = location.coordinate
                            settings.currentLocation = location
                        } else {
                            log.error("Location is not available yet")
                            // Handle the case when location is not available
                        }
                    }

                    //geoJSON
                    polyOverlays.removeAll()
        
                    locationIdViewModel.fetchLocations(latitude: circlePos?.latitude ?? 0, longitude: circlePos?.longitude ?? 0) { fetchedLocations in
                        // Use fetchedLocations here //actually it is one location
                        for location in fetchedLocations {
                            geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
                                polyOverlays = polyOverlaysIn
                                locationId = location.id
                                locationStr = location.name // the first is the same
                                
                                observationsLocationViewModel.fetchData(locationId: locationId, limit: 100, offset: 0, settings: settings, completion: {
                                    log.info("MapObservationsLocationView: fetchObservationsLocationData completed use delta")
                                    log.info(observationsLocationViewModel.span)
//                                    log.error(observationsLocationViewModel.observations?.results.count ?? 0) //??
                                    
                                    if settings.isFirstAppear {
                                        cameraPosition = MapCameraPosition
                                            .region(
                                                MKCoordinateRegion(
                                                    center: CLLocationCoordinate2D(
                                                        latitude: geoJSONViewModel.span.latitude,
                                                        longitude: geoJSONViewModel.span.longitude),
                                                    span: MKCoordinateSpan(
                                                        latitudeDelta: geoJSONViewModel.span.latitudeDelta,
                                                        longitudeDelta: geoJSONViewModel.span.longitudeDelta)
                                                )
                                            )
                                        settings.isFirstAppear = false
                                    }
                                    
                                }
                                )
                            }
                        }
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
    
    func getCameraPosition(settings: Settings, observationsLocationViewModel: ObservationsLocationViewModel, latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) -> MapCameraPosition {
        
        let center = CLLocationCoordinate2D(
            latitude: observationsLocationViewModel.span.latitude,
            longitude: observationsLocationViewModel.span.longitude)
        
        let span = MKCoordinateSpan(
            latitudeDelta: observationsLocationViewModel.span.latitudeDelta,
            longitudeDelta: observationsLocationViewModel.span.longitudeDelta)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        return MapCameraPosition.region(region)
    }
}


struct MapObservationLocationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationsLocationView()
            .environmentObject(Settings())
            .environmentObject(ObservationsViewModel())
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
            .environmentObject(KeychainViewModel())
        
    }
}
