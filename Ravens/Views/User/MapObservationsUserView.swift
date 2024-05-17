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
    @EnvironmentObject var userViewModel:  UserViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var showFullScreenMap = false
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    )
    
    @State private var limit = 100
    @State private var offset = 0
    
    @State private var start = 0
    @State private var end = 100
    
    @State private var showObservers: Bool = false
    
    @State private var showListView: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                                Text("\(start) + \(end)")
                                Spacer()
                                Text("\((observationsUserViewModel.observations?.count ?? 0) - offset) - \((observationsUserViewModel.observations?.count ?? 0) - offset + limit)")
                                    .foregroundColor(.obsGreenFlower)

                            }
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        }
                        
                    }
                    
                    HStack {
                        Spacer()
                        Text("Observations")
                            .bold()
                        Button(action: {
                            if let maxOffset = observationsUserViewModel.observations?.count {
                                log.info("maxOffset: \(maxOffset)")
                                offset = min(offset + 100, maxOffset)
                                limit = 100
                                observationsUserViewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") } )
                                start = 0
                                end = observationsUserViewModel.observations?.results.count ?? 0
                                
                            }
                        }) {
                            Image(systemName: "backward.fill")
                                .bold()
                        }
                        Button(action: {
                            if offset >= 100 {
                                offset = offset - 100
                            }
                            limit = 100
                            observationsUserViewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") })
                            
                            start = 0
                            end = observationsUserViewModel.observations?.results.count ?? 0
                        }) {
                            Image(systemName: "forward.fill")
                                .bold()
                        }
                        
                        Button(action: {
                            offset = 0
                            limit = 100
                            
                            observationsUserViewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") })
                        }) {
                            Image(systemName: "square.fill")
                        }

                    }
                    .frame(maxHeight: 30)
                }
                .padding(5)
                .bold()
                .foregroundColor(.obsGreenFlower)
                .background(Color.obsGreenEagle.opacity(0.5))
            }
            .mapStyle(settings.mapStyle)

            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() //tapping this makes it north
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ObserversView()) {
                    Label("Observers", systemImage: "person.2.fill")
                }
            }
            
            ToolbarItem() {
                HStack {
//                    Text("Observer")
                    Text("\(settings.userName)")
                }
            }
        }
        
        

        
        .onAppear {
//            observationsUserViewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") })
        }
    }
}

struct MapObservationUserView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        let testSpecies = Species(species: 62, name: "Unknown", scientific_name: "Scientific name", rarity: 1, native: true)
        MapObservationsSpeciesView(item: testSpecies)
            .environmentObject(Settings())
            .environmentObject(KeychainViewModel())
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
    }
}

