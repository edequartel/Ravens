//  MapObservationRadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationRadiusView: View {
    let log = SwiftyBeaver.self
    
    @State private var POIs: [POI] = []
    @ObservedObject var viewModel = POIViewModel()

    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var observationsRadiusViewModel: ObservationsRadiusViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var settings: Settings
    
//    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {

            VStack {
                MapReader { proxy in
                    Map(position: $settings.cameraRadiusPosition) { // centre and span for the camera
                        
                        UserAnnotation() //give dynamically the users position
                        

                        if (settings.poiOn) {
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
                            
                            if let circlePosition = settings.circlePos {
                                fetchDataLocation(location: circlePosition)
                            }
                            
                            
                        }
                    }
                    .mapControls() {
                        MapCompass()
                    }
                }
            }
            .onAppear() {
                print("xxx")
                setupInitialLocation()
                print("yyy")
               
            }
    }
    
    func colorByMapStyle() -> Color {
        if settings.mapStyleChoice == .standard {
            return Color.gray
        } else {
            return Color.white
        }
    }
    
    func setupInitialLocation() {
        //part 1 - only at init
        if settings.initialRadiusLoad { //this is published because of ObservatonsView
            let location = locationManagerModel.getCurrentLocation()
            settings.currentLocation = location
            settings.circlePos = location?.coordinate
            
            //for the Radius
            if let getlocation = location?.coordinate { //get the data for the location
                fetchDataLocation(location: getlocation)
            } else {
                log.error("error MapObservationsView getDataRadiusModel initialRadiusLoad")
            }
            settings.initialRadiusLoad = false
        }
        else {
            settings.circlePos = settings.currentLocation?.coordinate //get the saved location back
        }
        
        //part 2 when it radius depending Vars are changed
        if settings.isRadiusChanged { //in Radius in ettings changed is published
            if let circlePosition = settings.circlePos {
                fetchDataLocation(location: circlePosition)
            } else {
                log.info("error MapObservationsView getDataRadiusModel isRadiusChanged")
            }
            settings.isRadiusChanged = false
        }
    }

    func fetchDataLocation(location: CLLocationCoordinate2D) {
        observationsRadiusViewModel.fetchData(
            settings: settings,
            lat: location.latitude,
            long: location.longitude,
            completion: {
                log.error("MAP observationsViewModel.locations")
                settings.cameraRadiusPosition = observationsRadiusViewModel.getCameraPosition(
                    lat: location.latitude,
                    long: location.longitude,
                    radius: settings.radius)
            }
        )
    }
    
}

struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationRadiusView()
            .environmentObject(Settings())
            .environmentObject(ObservationsRadiusViewModel())
            .environmentObject(KeychainViewModel())
        
    }
}

