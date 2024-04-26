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
    
    @State private var locations: [Location] = []
    @State private var POIs: [POI] = []
    
    @ObservedObject var viewModel = POIViewModel()
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var userViewModel:  UserViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @ObservedObject var locationManager = LocationManager()
    
    @State private var showFullScreenMap = false
    @State private var circlePos: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                MapReader { proxy in
                    Map(position: $cameraPosition) { // centre and span for the camera
                        
                        UserAnnotation() //give dynamically the users position
                        
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
                        
                        // observations
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
                        
                        // Circle
                        MapCircle(center: circlePos ?? CLLocationCoordinate2D(), radius: CLLocationDistance(settings.radius))
                            .foregroundStyle(.clear.opacity(100))
                            .stroke(colorByMapStyle(), lineWidth: 2)
                        
                        
                    }
                    .mapStyle(settings.mapStyle)
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            SettingsDetailsView(count: observationsViewModel.locations.count, results: observationsViewModel.observations?.count ?? 0, showInfinity: false )
                            
                            //
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
                        .padding(5)
                        .foregroundColor(.obsGreenFlower)
                        .background(Color.obsGreenEagle.opacity(0.5))
                    }
                    .onTapGesture() { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            circlePos = CLLocationCoordinate2D(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )
                            
                            settings.currentLocation = CLLocation(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )

                            fetchDataModel()
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
            ObservationsView()
        }
        
        .onAppear() {
            log.info("MapObservationView onAppear")
            
            //getUser
            userViewModel.fetchUserData(settings: settings, completion: {
                log.info("userViewModel.fetchUserData userid \(userViewModel.user?.id ?? 0)")
                settings.userId = userViewModel.user?.id ?? 0
            })
            
            //get the POIs
            viewModel.fetchPOIs(completion: { POIs = viewModel.POIs} )
            
            //get the location
            if settings.initialLoad {
                log.info("MapObservationView initiaLLoad, get data at startUp and Position")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //opstarten
                    settings.currentLocation = self.locationManager.location
                    circlePos = settings.currentLocation?.coordinate
                    
                    //get the observations
                    fetchDataModel()
                    cameraPosition = getCameraPosition()
                    
                    //only once
                    settings.initialLoad = false
                }
            } else {
                log.info("MapObservationView NOT initiaLLoad")
//                circlePos = settings.currentLocation?.coordinate
//                
//                //get the observations
                fetchDataModel()
//                cameraPosition = getCameraPosition()
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
            latitude: settings.currentLocation?.coordinate.latitude ?? 0,
            longitude: settings.currentLocation?.coordinate.longitude ?? 0)
        
        let span = MKCoordinateSpan(
            latitudeDelta: Double(settings.radius) * 0.00004,
            longitudeDelta: Double(settings.radius) * 0.00004)
        
        
        let region = MKCoordinateRegion(center: center, span: span)
        return MapCameraPosition.region(region)
    }
    
    func fetchDataModel() {
        observationsViewModel.fetchData(
            lat: circlePos?.latitude ?? 0,
            long: circlePos?.longitude ?? 0,
            settings: settings,
            completion: { locations = observationsViewModel.locations }
        )
    }
    
}

struct MapObservationView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationView()
            .environmentObject(Settings())
            .environmentObject(ObservationsViewModel())
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
            .environmentObject(KeychainViewModel())
        
    }
}
