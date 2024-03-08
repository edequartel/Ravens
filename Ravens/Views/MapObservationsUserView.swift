//
//  MapObservationsUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationsUserView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var limit = 100
    @State private var offset = 0
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 6, longitudeDelta: 4)
        )
    )
    
    @State private var isSheetObservationsViewPresented = false
    
//    var speciesID: Int
//    var speciesName: String
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(observationsUserViewModel.locations) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
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
                    NetworkView()
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(observationsUserViewModel.observationsSpecies?.count ?? 0)x")
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                    }
                    Spacer()
                    HStack {
                        Button {
                            if let maxOffset = observationsUserViewModel.observationsSpecies?.count {
                                offset = min(offset + 100, maxOffset)
                                limit = 100
                                observationsUserViewModel.fetchData(limit: limit, offset: offset)
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        
                        Button {
                            if offset >= 100 {
                                offset = offset - 100
                            }
                            limit = 100
                            observationsUserViewModel.fetchData(limit: limit, offset: offset)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        Text("\(offset)")
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
//            ObservationsUserView()
            
            ObservationsUserViewExtra(viewModel: observationsUserViewModel)
            
            
        }
        .onAppear {
            observationsUserViewModel.fetchData(limit: limit, offset: offset)
        }
    }
}

struct MapObservationUserView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationsSpeciesView(speciesID: 62, speciesName: "Unknown")
            .environmentObject(Settings())
            .environmentObject(KeychainViewModel())
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
    }
}

