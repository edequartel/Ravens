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
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var locationIdViewModel: LocationIdViewModel
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
    @EnvironmentObject var poiViewModel: POIViewModel
    
    var body: some View {
//        VStack {
//            ZStack(alignment: .topLeading) {
                VStack {
                    MapReader { proxy in
                        Map(position: $settings.cameraAreaPosition) {
                            
                            UserAnnotation()
                            
                            //                      POI
                            //                        if (settings.poiOn) {
                            ForEach(areasViewModel.records, id: \.id) { record in
                                Annotation(record.name,
                                           coordinate: CLLocationCoordinate2D(
                                            latitude: record.latitude,
                                            longitude: record.longitude)) {
                                                Triangle()
                                                    .fill(Color.gray)
                                                    .frame(width: 10, height: 10)
                                                    .overlay(
                                                        Triangle()
                                                            .stroke(Color.red, lineWidth: 1)
                                                            .fill(Color.red)// Customize the border color and width
                                                    )
                                            }
                            }
                            //                        }
                            
                            
                            // location observations
                            ForEach(observationsLocationViewModel.locations.filter { $0.rarity >= settings.selectedRarity })
                            { location in
                                
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Circle()
                                        .fill(RarityColor(value: location.rarity))
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
                                settings.currentLocation = CLLocation(
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude
                                )
                                
                                fetchDataLocation(coordinate: coordinate)
                            }
                        }
                        
                        .mapControls() {
                            MapCompass() //tapping this makes it north
                        }
                    }
                }
                .onAppear() {
                    log.info("MapObservationsLocationView onAppear")
                    getDataAreaModel()
                }
//            }
//        }
    }
    
    func getDataAreaModel() {
        log.info("getDataAreaModel")
        if settings.initialAreaLoad {
            log.info("MapObservationsLocationView onAppear")
            if locationManagerModel.checkLocation() {
                let location = locationManagerModel.getCurrentLocation()
                settings.currentLocation = location
                fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.error("error observationsLocationsView getDataAreaModel initialAreaLoad")
            }
            settings.initialAreaLoad = false
        }
        
        if settings.isAreaChanged {
            log.error("isAreaChanged")
            if locationManagerModel.checkLocation() {
                let location = settings.currentLocation
                fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.error("error observationsLocationsView getDataAreaModel isAreaChanged")
            }
            settings.isAreaChanged = false
        }
        
        if settings.isLocationIDChanged {
            log.error("isAreaChanged")
            if locationManagerModel.checkLocation() {
                fetchDataLocationID()
            } else {
                log.error("error observationsLocationsView getDataAreaModel isLocationIDChanged")
            }
            settings.isLocationIDChanged = false
        }
        
    }
    
    func fetchDataLocation(coordinate: CLLocationCoordinate2D) {
        log.info("MapObservationsLocationView fetchDataLocation")
        locationIdViewModel.fetchLocations(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            completion: { fetchedLocations in
                log.info("MaplocationIdViewModel data loaded")
                // Use fetchedLocations here //actually it is one location
                settings.locationName = fetchedLocations[0].name
                settings.locationId = fetchedLocations[0].id
                settings.locationCoordinate = CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude)
                
                for location in fetchedLocations {
                    log.info("locatiob \(location)")
                }
                
                //1. get the geoJSON for this area / we pick the first one = 0
                geoJSONViewModel.fetchGeoJsonData(
                    for: fetchedLocations[0].id,
                    completion:
                        {
                            log.info("geoJSONViewModel data loaded")
                            
                            //2. get the observations for this area
                            observationsLocationViewModel.fetchData(
                                settings: settings,
                                locationId: fetchedLocations[0].id,
                                limit: 100,
                                offset: 0,
                                completion: {
                                    log.info("observationsLocationViewModel data loaded")
                                    settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition() //automatic
                                })
                        }
                )
            })
    }

    func fetchDataLocationID() {
        log.error("fetchDataLocationID")
        //1. get the geoJSON for this area / we pick the first one = 0
        geoJSONViewModel.fetchGeoJsonData(
            for: settings.locationId,
            completion:
                {
                    log.error("geoJSONViewModel data loaded")
                    
                    //2. get the observations for this area
                    observationsLocationViewModel.fetchData(
                        settings: settings,
                        locationId: settings.locationId,
                        limit: 100,
                        offset: 0,
                        completion: {
                            log.info("observationsLocationViewModel data loaded")
                            
                            settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition() //automatic of not?
                            
                        })
                }
        )
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


