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
    
    @State private var limit = 100
    @State private var offset = 0
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    )
    
    var speciesID: Int
    var speciesName: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(observationsSpeciesViewModel.locations) { location in
                    Annotation("", coordinate: location.coordinate) {
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
                        //
                        Spacer()
                        Text("\((observationsSpeciesViewModel.observationsSpecies?.count ?? 0))x")
                            .foregroundColor(.obsGreenFlower)
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        //
                        Text("\(speciesName)")
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        //
                        Text("\(settings.days)d")
                        Text("\(settings.selectedDate, formatter: dateFormatter)")
                    }
                    
                    //
                    HStack {
                        Spacer()
                        Text("days")
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
                            if let newDate = Calendar.current.date(byAdding: .day, value: settings.days, to: settings.selectedDate) {
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
        .onAppear {
            fetchDataModel()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE dd-MM"
        return formatter
    }
    
    func fetchDataModel() {
        // Debugging or additional actions
        observationsSpeciesViewModel.fetchData(
            speciesId: speciesID,
            limit: 100,
            offset: 0,
            date: settings.selectedDate,
            days: settings.days
        )
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

