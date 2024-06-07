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
    @EnvironmentObject var locationIdViewModel: LocationIdViewModel
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
    @EnvironmentObject var poiViewModel: POIViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        
//                        UserAnnotation()
                        
                        // POI
                        if (settings.poiOn) {
                            ForEach(poiViewModel.POIs, id: \.name) { poi in
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
                        
                        // geoJSON
                        ForEach(geoJSONViewModel.polyOverlays, id: \.self) { polyOverlay in
                            MapPolygon(polyOverlay)
                                .stroke(.pink, lineWidth: 1)
                                .foregroundStyle(.blue.opacity(0.1))
                        }
                        
                    }
                    
                    .mapStyle(settings.mapStyle)
                    
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            SettingsDetailsView(
                                count: observationsLocationViewModel.locations.count,
                                results: observationsLocationViewModel.count)
                        }
                        .padding(5)
                        .foregroundColor(.obsGreenFlower)
                        .background(Color.obsGreenEagle.opacity(0.5))
                    }
                    
                    .onTapGesture() { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            fetchLocationData(coordinate: coordinate)
                        }
                        cameraPosition = getCameraPosition()
                    }

                    .mapControls() {
                        MapCompass() //tapping this makes it north
                        
                    }
                }
            }
            .onAppear() {
                if settings.initialLoadArea {
                    log.info("MapObservationsLocationView onAppear")
                    if locationManagerModel.checkLocation() {
                        let location = locationManagerModel.getCurrentLocation()
                        let defaultCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                        fetchLocationData(coordinate: location?.coordinate ?? defaultCoordinate)
                        settings.initialLoadArea = false
                    }
                }
            }
        }
    }
    
    
    func fetchLocationData(coordinate: CLLocationCoordinate2D) {
        locationIdViewModel.fetchLocations(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            completion: { fetchedLocations in
                log.info("locationIdViewModel data loaded")
                // Use fetchedLocations here //actually it is one location
                settings.locationName = fetchedLocations[0].name
                settings.locationId = fetchedLocations[0].id
                for location in fetchedLocations {
                    log.error(location)
                }
                
                //1. get the geoJSON for this area / we pick the first one = 0
                geoJSONViewModel.fetchGeoJsonData(
                    for: fetchedLocations[0].id,
                    completion:
                        {
                            log.info("geoJSONViewModel data loaded")
                            //2. get the observations for this area
                            observationsLocationViewModel.fetchData( //settings??
                                locationId: fetchedLocations[0].id,
                                limit: 100,
                                offset: 0,
                                settings: settings,
                                completion: {
                                    log.info("observationsLocationViewModel data loaded")
//                                    cameraPosition = getCameraPosition()
                                })
                        }
                )
            })
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
}

//struct MapObservationLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Setting up the environment objects for the preview
//        MapObservationsLocationView()
//            .environmentObject(Settings())
//            .environmentObject(ObservationsRadiusViewModel())
////            .environmentObject(SpeciesGroupViewModel())
//            .environmentObject(KeychainViewModel())
//        
//    }
//}


//        .onAppear() {
//            log.error("MapObservationLocationView onAppear")
//
//            //get the POIs
//            viewModel.fetchPOIs(completion: { POIs = viewModel.POIs} )
//
//            //get the location
//            if settings.initialLoadLocation {
//                log.error("MapObservationView initiaLLoad, get data at startUp and Position")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //opstarten
////                    settings.currentLocation = self.locationManager.location
//
//
//                    //get the observations
//                    //geoJSON
//                    polyOverlays.removeAll()
//                    locationIdViewModel.fetchLocations(
//                        latitude: settings.currentLocation?.coordinate.latitude ?? 0,
//                        longitude: settings.currentLocation?.coordinate.longitude ?? 0) { fetchedLocations in
//                            // Use fetchedLocations here //actually it is one location
////                            for location in fetchedLocations {
////                                geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
////                                    polyOverlays = polyOverlaysIn
////                                    settings.locationId = location.id
////                                    settings.locationName = location.name // the first is the same
////
////                                    print(">>>> \(settings.locationName) \(settings.locationId)")
////
////                                    fetchDataModel()
////                                    cameraPosition = getCameraPosition()
////                                }
////                            }
//                        }
//
//                    //only once
//                    settings.initialLoadLocation = false
//                }
//            } else {
////                circlePos = settings.currentLocation?.coordinate
////                settings.currentLocation = self.locationManager.location
////                settings.locationId = location.id
////                settings.locationStr = location.name // the first is the same
////                cameraPosition = getCameraPosition()
//
//
//                fetchDataModel()
//            }
//
//            //get selectedGroup
//            log.verbose("settings.selectedGroupId:  \(settings.selectedSpeciesGroup)")
//            speciesGroupsViewModel.fetchData(language: settings.selectedLanguage)
//        }


//HStack {
//                                if settings.infinity {
//                                    Spacer()
//                                }
                                
                                
//                                if !settings.infinity {
//                                    Spacer()
//                                    HStack {
//                                        Spacer()
//                                        Text("days ")
//                                            .bold()
//                                        Button(action: {
//                                            if let newDate = Calendar.current.date(byAdding: .day, value: -settings.days, to: settings.selectedDate) {
//                                                settings.selectedDate = min(newDate, Date())
//                                            }
//                                            fetchDataModel()
//                                        }) {
//                                            Image(systemName: "backward.fill")
//                                                .background(Color.clear)
//                                        }
//
//                                        Button(action: {
//                                            // Calculate the potential new date by adding days to the selected date
//                                            if let newDate = Calendar.current.date(byAdding: .day, value: settings.days, to: settings.selectedDate) {
//                                                // Ensure the new date does not go beyond today
//                                                settings.selectedDate = min(newDate, Date())
//                                            }
//                                            fetchDataModel()
//
//                                        }) {
//                                            Image(systemName: "forward.fill")
//                                        }
//
//                                        Button(action: {
//                                            settings.selectedDate = Date()
//                                            log.info("Date updated to \(settings.selectedDate)")
//                                            fetchDataModel()
//                                        }) {
//                                            Image(systemName: "square.fill")
//                                        }
//                                    }
//                                    .frame(maxHeight: 30)
//                                }
//                            }
