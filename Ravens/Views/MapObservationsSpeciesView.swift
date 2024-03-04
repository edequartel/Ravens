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
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 6, longitudeDelta: 4)
        )
    )
    
    @State private var isSheetObservationsViewPresented = false
    
    var speciesID: Int
    var speciesName: String
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(observationsSpeciesViewModel.locations) { location in
                    Annotation("", coordinate: location.coordinate) {
                        Circle()
                            .fill(Color(myColor(value: location.rarity)))
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(location.hasPhoto ? Color.red : Color.white, lineWidth: 1)
                            )
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                        .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .obsGreenFlower)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(speciesName) \(observationsSpeciesViewModel.observationsSpecies?.count ?? 0)x")
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                    }
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .foregroundColor(.obsGreenFlower)
                .background(Color.obsGreenEagle.opacity(0.5))
            }
            
            .mapStyle(.hybrid(elevation: .realistic))
//            .mapStyle(.standard(elevation: .realistic))
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
            observationsSpeciesViewModel.fetchData(speciesId: speciesID, limit: 100)
        }
    }
}

struct MapObservationSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationsSpeciesView(speciesID: 62, speciesName: "Unknown")
            .environmentObject(Settings())
            .environmentObject(KeychainViewModel())
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
    }
}

