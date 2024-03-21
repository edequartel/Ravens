//
//  MapObservationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
}

struct MapObservationView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
//    @State private var myPosition : MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var cameraPosition = MapCameraPosition
        .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), //<<< userlocation
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    @ObservedObject var locationManager = LocationManager()
    @State private var circlePos: CLLocationCoordinate2D?
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    
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
                        .stroke(.white, lineWidth: 1)
                    
                }
                .mapStyle(.hybrid(elevation: .realistic))
                
                
                
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        SettingsDetailsView(count: observationsViewModel.locations.count, results: observationsViewModel.observations?.count ?? 0 )
                    } 
                }
                
                .onTapGesture() { position in //get all the data from the location
                    //                    if let coordinate = proxy.convert(position, from: .local) {
                    //                        observationsViewModel.fetchData(lat: coordinate.latitude, long: coordinate.longitude)
                    //                        circlePos = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    //                    }
                    //
                    
                    if let coordinate = proxy.convert(position, from: .local) {
                        observationsViewModel.fetchData(lat: coordinate.latitude, long: coordinate.longitude)
                        
                        // Create a new CLLocation instance with the updated coordinates
                        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        circlePos = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                        // Update currentLocation with the new CLLocation instance
                        settings.currentLocation = newLocation
                    }
                    
                    
                    
                    //
                    
                    
                    
                }
                
                .mapControls() {
//                    MapUserLocationButton()
                    MapCompass() //tapping this makes it north
                }
            }
        }
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let location = self.locationManager.location {
                    let myLatitude = location.coordinate.latitude
                    let myLongitude = location.coordinate.longitude
                    print("My location is: \(myLatitude), \(myLongitude)")
                    circlePos = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    observationsViewModel.fetchData(lat: myLatitude, long: myLongitude)
                } else {
                    print("Location is not available yet")
                    // Handle the case when location is not available
                }
                
                log.verbose("settings.selectedGroupId:  \(settings.selectedGroup)")
                speciesGroupViewModel.fetchData(completion: { _ in log.info("fetcheddata speciesGroupViewModel") })
            }
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
