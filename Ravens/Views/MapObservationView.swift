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

    @ObservedObject var viewModel = POIViewModel()
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @ObservedObject var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition?
    @State private var isSheetObservationsViewPresented = false
    @State private var MapCameraPositiondefault = MapCameraPosition
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        )

    @State private var circlePos: CLLocationCoordinate2D?
    
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
                        
                        ForEach(observationsViewModel.locations) { location in
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
                        
                        MapCircle(center: circlePos ?? CLLocationCoordinate2D(), radius: CLLocationDistance(settings.radius))
                            .foregroundStyle(.clear.opacity(100))
                            .stroke(colorByMapStyle(), lineWidth: 1)
                    }
                    .mapStyle(settings.mapStyle)
                    
                    .safeAreaInset(edge: .bottom) {
                        SettingsDetailsView(count: observationsViewModel.locations.count, results: observationsViewModel.observations?.count ?? 0, showInfinity: false )
                    }
                    
                    .onTapGesture() { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            observationsViewModel.fetchData(lat: coordinate.latitude, long: coordinate.longitude,
                                                            completion: {
                                log.info("fetchData observationsViewModel completed")
                            } )
                            
                            // Create a new CLLocation instance with the updated coordinates
                            let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            circlePos = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            
                            // Update currentLocation with the new CLLocation instance
                            settings.currentLocation = newLocation //?? why>>for other sheetview
                        }
                    }
                    .mapControls() {
                        MapCompass() //tapping this makes it north
                    }
                }
            }
            
            ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "f7b731")
        }

        //
        .sheet(isPresented: $isSheetObservationsViewPresented) {
            ObservationsView(isShowing: $isSheetObservationsViewPresented)
        }
        //
        
       .onAppear() {
            viewModel.fetchPOIs()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                if settings.isFirstAppearObsView {
                    
                    if let location = self.locationManager.location {
                        log.info("get the location at onAppear in MapObservationView")
                        circlePos = location.coordinate
                        settings.currentLocation = location
                    } else {
                        log.error("Location is not available yet")
                        // Handle the case when location is not available
                    }
                }
                
                //getdata
                observationsViewModel.fetchData(lat: circlePos?.latitude ?? 0, long: circlePos?.longitude ?? 0,
                                                completion: {
                    log.info("fetchData observationsViewModel ONAPPEAR completed")
                    
                    // Initialize cameraPosition with user's current location
                    if settings.isFirstAppearObsView {
                        let delta = Double(settings.radius) * 0.000032
                        cameraPosition = MapCameraPosition
                            .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: circlePos?.latitude ?? 0,
                                                                   longitude: circlePos?.longitude ?? 0),
                                    span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
                                )
                            )
                        settings.isFirstAppearObsView = false
                    }

                } 
                )
                //

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


struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationView()
            .environmentObject(Settings())
            .environmentObject(ObservationsViewModel(settings: Settings()))
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
            .environmentObject(KeychainViewModel())
        
    }
}
