//
//  MapObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 19/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationsSpeciesView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    @StateObject private var authManager = AuthManager()
//    @State private var position : MapCameraPosition = .userLocation(fallback: .automatic)
    //    @State private var position : MapCameraPosition = .automatic
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 4)
        )
    )
    
    @State private var isSheetObservationsViewPresented = false
    
    var speciesID: Int
    var speciesName: String
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(observationsSpeciesViewModel.locations) { location in
                    Marker("", systemImage: "binoculars.fill", coordinate:  location.coordinate)
                        .tint(Color(myColor(value: location.rarity)))
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    VStack(alignment: .trailing) {
                        Text("\(speciesName)")
                            .padding(5)
                            .font(.headline)
                            .foregroundColor(.obsGreenFlower)
                            .background(Color.obsGreenEagle.opacity(0.5))
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        SettingsDetailsView(count: observationsSpeciesViewModel.locations.count)
                    }
                }
                .padding(2)
                .font(.footnote)
                .foregroundColor(.obsGreenFlower)
            }
            
            .mapStyle(.hybrid(elevation: .realistic))
            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() //tapping this makes it north
            }
            
            ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "f7b731")
        }
        .sheet(isPresented: $isSheetObservationsViewPresented) {
            ObservationsSpeciesView(speciesID: speciesID, speciesName: speciesName)
        }
        .onAppear {
            observationsSpeciesViewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate, days: settings.days, token: authManager.token ?? "noToken")
        }
    }
}

struct MapObservationSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationsSpeciesView(speciesID: 62, speciesName: "Unknown")
            .environmentObject(ObservationsSpeciesViewModel())
            .environmentObject(Settings())
    }
}

