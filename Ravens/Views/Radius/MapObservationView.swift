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
    
    @State private var POIs: [POI] = []
    @ObservedObject var viewModel = POIViewModel()

    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var observationsRadiusViewModel: ObservationsRadiusViewModel
    @EnvironmentObject var settings: Settings
    
//    @State private var circlePos: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @State private var initialLoad = true
    
    var body: some View {

            VStack {
                MapReader { proxy in
                    Map(position: $cameraPosition) { // centre and span for the camera
                        
//                        UserAnnotation() //give dynamically the users position
                        
                        // POI
                        if (settings.poiOn) {
                            ForEach(POIs, id: \.name) { poi in
                                Annotation(poi.name, coordinate: poi.coordinate.cllocationCoordinate) {
                                    Triangle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                                        .overlay(
                                            Triangle()
                                                .stroke(Color.red, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        
                        // observations
                        ForEach(observationsRadiusViewModel.locations) { location in
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
                        
                        // Circle
                        MapCircle(center: settings.circlePos ?? CLLocationCoordinate2D(), radius: CLLocationDistance(settings.radius))
                            .foregroundStyle(.clear.opacity(100))
                            .stroke(colorByMapStyle(), lineWidth: 2)
                        
                        
                    }
                    .mapStyle(settings.mapStyle)
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            SettingsDetailsView(count: observationsRadiusViewModel.locations.count, results: observationsRadiusViewModel.observations?.count ?? 0, showInfinity: false )
                        }
                        .padding(5)
                        .foregroundColor(.obsGreenFlower)
                        .background(Color.obsGreenEagle.opacity(0.5))
                    }
                    .onTapGesture() { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            settings.circlePos = CLLocationCoordinate2D(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )
                            
                            settings.currentLocation = CLLocation(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )

//                            fetchDataModel()
                            
                            if let circlePosition = settings.circlePos {
                                fetchDataLocation(location: circlePosition)
                            }
                            
//                            cameraPosition = getCameraPosition()
                        }
                    }
                    .mapControls() {
                        MapCompass()
                    }
                }
            }
            .onAppear() {
                setupInitialLocation()
//                cameraPosition = getCameraPosition()
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
            latitude: settings.currentLocation?.coordinate.latitude ?? 0,
            longitude: settings.currentLocation?.coordinate.longitude ?? 0)
        
        let span = MKCoordinateSpan(
            latitudeDelta: Double(settings.radius) * 0.00004,
            longitudeDelta: Double(settings.radius) * 0.00004)
        
        
        let region = MKCoordinateRegion(center: center, span: span)
        return MapCameraPosition.region(region)
    }
    
    
    func fetchDataLocation(location: CLLocationCoordinate2D) {
        observationsRadiusViewModel.fetchData(
            lat: location.latitude,
            long: location.longitude,
            settings: settings,
            completion: { print("observationsViewModel.locations") }
        )
    }
    
    func setupInitialLocation() {
        if settings.initialRadiusLoad {
            print("MAP only when start first time")
            let location = locationManagerModel.getCurrentLocation()
            settings.currentLocation = location
            settings.circlePos = location?.coordinate
            
            //for the Radius
            if let circlePosition = settings.circlePos {
                fetchDataLocation(location: circlePosition)
            }

            settings.initialRadiusLoad = false
            }
        else {
            settings.circlePos = settings.currentLocation?.coordinate
        }

        if settings.isRadiusChanged {
            print("changed Radius")
            if let circlePosition = settings.circlePos {
                fetchDataLocation(location: circlePosition)
            }
            settings.isRadiusChanged = false
        }
    }

}

struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationView()
            .environmentObject(Settings())
            .environmentObject(ObservationsRadiusViewModel())
            .environmentObject(KeychainViewModel())
        
    }
}

