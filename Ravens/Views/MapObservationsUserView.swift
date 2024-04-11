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
    
//    @State private var myPosition : MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    )
    
    @State private var limit = 100
    @State private var offset = 0
    
    @State private var elevation: MapStyle.Elevation = .realistic
    @State private var isSheetObservationsViewPresented = false
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(observationsUserViewModel.locations) { location in
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
                
                
                
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    HStack {
                        Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                            .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .obsGreenFlower)
                        NetworkView()
                        Spacer()
                        VStack(alignment: .trailing) {
                            HStack{
                                Spacer()
                                Text("\((observationsUserViewModel.observations?.count ?? 0) - offset) - \((observationsUserViewModel.observations?.count ?? 0) - offset + limit)")
                                    .foregroundColor(.obsGreenFlower)

                            }
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        }
                    }
                    .padding(5)
                    .frame(maxHeight: 30)
                    
                    HStack {
                        Spacer()
                        Text("count ")
                            .bold()
                        Button(action: {
                            if let maxOffset = observationsUserViewModel.observations?.count {
                                log.info("maxOffset: \(maxOffset)")
                                offset = min(offset + 100, maxOffset)
                                limit = 100
                                observationsUserViewModel.fetchData(limit: limit, offset: offset)
                            }
                        }) {
                            Image(systemName: "minus.rectangle")
                            //                                .font(.title)
                        }
                        Button(action: {
                            if offset >= 100 {
                                offset = offset - 100
                            }
                            limit = 100
                            observationsUserViewModel.fetchData(limit: limit, offset: offset)
                        }) {
                            Image(systemName: "plus.rectangle")
                            //                                .font(.title)
                        }

                    }
                    .padding(5)
                    .frame(maxHeight: 30)
                }
                
                .font(.headline)
                .foregroundColor(.obsGreenFlower)
                .background(Color.obsGreenEagle.opacity(0.5))
            }
            
            
            .mapStyle(settings.mapStyle)
            
            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() //tapping this makes it north
            }
            
            ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "77b731")
        }
        
        .sheet(isPresented: $isSheetObservationsViewPresented) {
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

