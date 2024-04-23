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
    
    @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    @StateObject private var locationIdViewModel = LocationIdViewModel()
    @StateObject private var geoJSONViewModel = GeoJSONViewModel()
    @ObservedObject var viewModel = POIViewModel()
    @ObservedObject var locationManager = LocationManager()
    
    @State private var locations: [Location] = []
    @State private var POIs: [POI] = []
    @State private var polyOverlays = [MKPolygon]()
    
    @State private var showFullScreenMap = false
    
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        
                        UserAnnotation()
                        
                        // POI
                        if (settings.poiOn) {
                            ForEach(POIs, id: \.name) { poi in
                                Annotation(poi.name, coordinate: poi.coordinate.cllocationCoordinate) {
                                    Triangle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                                        .overlay(
                                            Triangle()
                                                .stroke(Color.red, lineWidth: 1) // Customize the border color and width
                                        )
                                }
                            }
                        }
                        
                        // location observations
                        ForEach(locations) { location in
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
                        
                        // geoJSON
                        ForEach(polyOverlays, id: \.self) { polyOverlay in
                            MapPolygon(polyOverlay)
                                .stroke(.pink, lineWidth: 1)
                                .foregroundStyle(.blue.opacity(0.1))
                        }
                    }
                    
                    .mapStyle(settings.mapStyle)
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            SettingsDetailsView(count: observationsLocationViewModel.locations.count, results: observationsLocationViewModel.count) //??
                            HStack {
                                if settings.infinity {
                                    Spacer()
                                }
                                HStack {
                                    //                                    Spacer()
                                    let text = locationIdViewModel.locations.count > 0 ? "\(locationIdViewModel.locations[0].name)" : "Default Name"
                                    Text(text)
                                        .frame(height: 30)
                                        .lineLimit(1)
                                }
                                .bold()
                                .frame(maxHeight: 30)
                                
                                
                                
                                if !settings.infinity {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("days ")
                                            .bold()
                                        Button(action: {
                                            if let newDate = Calendar.current.date(byAdding: .day, value: -settings.days, to: settings.selectedDate) {
                                                settings.selectedDate = min(newDate, Date())
                                            }
                                            fetchDataModel()
                                        }) {
                                            Image(systemName: "backward.fill")
                                                .background(Color.clear)
                                        }
                                        
                                        Button(action: {
                                            // Calculate the potential new date by adding days to the selected date
                                            if let newDate = Calendar.current.date(byAdding: .day, value: settings.days, to: settings.selectedDate) {
                                                // Ensure the new date does not go beyond today
                                                settings.selectedDate = min(newDate, Date())
                                            }
                                            fetchDataModel()
                                            
                                        }) {
                                            Image(systemName: "forward.fill")
                                        }
                                        
                                        Button(action: {
                                            settings.selectedDate = Date()
                                            log.info("Date updated to \(settings.selectedDate)")
                                            fetchDataModel()
                                        }) {
                                            Image(systemName: "square.fill")
                                        }
                                    }
                                    .frame(maxHeight: 30)
                                }
                            }
                        }
                        .padding(5)
                        .foregroundColor(.obsGreenFlower)
                        .background(Color.obsGreenEagle.opacity(0.5))
                    }
                    .onTapGesture() { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            settings.tappedCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            
//                            print("Tapped coordinate: \(settings.tappedCoordinate)")
                            
                            //lat,long -> locationId -> geoJSON > observation -> locations
                            polyOverlays.removeAll()
                            locationIdViewModel.fetchLocations(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude) { fetchedLocations in
                                    // Use fetchedLocations here, er is er echter altijd maar 1 daarom pakken we de eerste
                                    for location in fetchedLocations {
                                        
                                        log.info(location.id) //dit is de locatieId en hiermee halen we de geoJSON data op
                                        geoJSONViewModel.fetchGeoJsonData(
                                            for: String(location.id),
                                            completion: { polyOverlaysIn in
                                                polyOverlays = polyOverlaysIn
                                                settings.locationId = location.id
                                                settings.locationStr = location.name // the first is the same
                                                
                                                fetchDataModel()
                                            } )
                                    }
                                }
                            
                            // Update currentLocation with the new CLLocation instance
                            settings.currentLocation = CLLocation(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )
                        }
                    }
                    .mapControls() {
                        MapCompass() //tapping this makes it north
                        
                    }
                }
            }
            
            CircleButton(isToggleOn: $showFullScreenMap)
                .topLeft()
            
        }
        .fullScreenCover(isPresented: $showFullScreenMap) {
            ObservationsLocationView(
                locationId: settings.locationId,
                locationStr: settings.locationStr
            )
        }
        
        .onAppear() {
            log.error("MapObservationLocationView onAppear")
            
            //get the POIs
            viewModel.fetchPOIs(completion: { POIs = viewModel.POIs} )
            
            //get the location
            if settings.initialLoadLocation {
                
                log.info("MapObservationView initiaLLoad, get data at startUp and Position")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //opstarten
                    settings.currentLocation = self.locationManager.location
                    
                    //get the observations
                    //geoJSON
                    polyOverlays.removeAll()
                    locationIdViewModel.fetchLocations(
                        latitude: settings.currentLocation?.coordinate.latitude ?? 0,
                        longitude: settings.currentLocation?.coordinate.longitude ?? 0) { fetchedLocations in
                            // Use fetchedLocations here //actually it is one location
                            for location in fetchedLocations {
                                geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
                                    polyOverlays = polyOverlaysIn
                                    settings.locationId = location.id
                                    settings.locationStr = location.name // the first is the same
                                    
                                    fetchDataModel()
                                    cameraPosition = getCameraPosition()
                                }
                            }
                        }
                    
                    //only once
                    settings.initialLoadLocation = false
                }
            } 
            
            //get selectedGroup
            log.verbose("settings.selectedGroupId:  \(settings.selectedGroup)")
            speciesGroupViewModel.fetchData(language: settings.selectedLanguage)
        }
    }
    
    
    func colorByMapStyle() -> Color {
        if settings.mapStyleChoice == .standard {
            return Color.gray
        } else {
            return Color.white
        }
    }
    
    func getCameraPosition() -> MapCameraPosition {
        let center = CLLocationCoordinate2D(
            latitude: geoJSONViewModel.span.latitude,
            longitude: geoJSONViewModel.span.longitude)
        
        let span = MKCoordinateSpan(
            latitudeDelta: geoJSONViewModel.span.latitudeDelta,
            longitudeDelta: geoJSONViewModel.span.longitudeDelta)
        
        
        let region = MKCoordinateRegion(center: center, span: span)
        return MapCameraPosition.region(region)
    }
    
    func fetchDataModel() {
        observationsLocationViewModel.fetchData(
            locationId:  settings.locationId,
            limit: 100,
            offset: 0,
            settings: settings,
            completion: {
                locations = observationsLocationViewModel.locations
                log.info(observationsLocationViewModel.span)
                
//                cameraPosition = getCameraPosition()
            } )
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


