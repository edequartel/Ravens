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
    
    var item: Species
    
    @State private var limit = 100
    @State private var offset = 0
    @State private var showFullScreenMap = false
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .leading) {
            Map(position: $cameraPosition) {
//                UserAnnotation()
                
                ForEach(observationsSpeciesViewModel.locations) { location in
                    Annotation("", coordinate: location.coordinate) {
                        Circle()
                            .fill(rarityColor(value: location.rarity))
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
            .onAppear() {
                fetchDataModel()
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    HStack {
//                        NetworkView()
                        //
                       
                        Text("\((observationsSpeciesViewModel.observationsSpecies?.count ?? 0))x")
                            .foregroundColor(.obsGreenFlower)
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        //
                        Text("\(item.name)")
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        //
                        Text("\(14)d")
                        Text("\(settings.selectedDate, formatter: dateFormatter)")
                        Spacer()
                    }
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
            
//            Button("Dismiss") {
//                self.presentationMode.wrappedValue.dismiss()
//            }
//            .topLeft()
            
        }
        .onAppear {
            if settings.initialSpeciesLoad {
                fetchDataModel()
                settings.initialSpeciesLoad = false
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE dd-MM"
        return formatter
    }
    
    func fetchDataModel() {
        observationsSpeciesViewModel.fetchData(
            settings: settings,
            speciesId: item.id,
            limit: 100,
            offset: 0
        )
    }
}


struct MapObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        let testSpecies = Species(species: 62, name: "Unknown", scientific_name: "Scientific name", rarity: 1, native: true, time: "00:00", date: "1900-01-01")
        MapObservationsSpeciesView(item: testSpecies)
            .environmentObject(Settings())
            .environmentObject(KeychainViewModel())
            .environmentObject(ObservationsSpeciesViewModel())
    }
}

//HStack {
//    Spacer()
//    Text("days")
//        .bold()
//    Button(action: {
//        if let newDate = Calendar.current.date(byAdding: .day, value: -settings.days, to: settings.selectedDate) {
//            settings.selectedDate = min(newDate, Date())
//        }
//        fetchDataModel()
//    }) {
//        Image(systemName: "backward.fill")
//    }
//    
//    Button(action: {
//        if let newDate = Calendar.current.date(byAdding: .day, value: settings.days, to: settings.selectedDate) {
//            settings.selectedDate = min(newDate, Date())
//        }
//        fetchDataModel()
//    }) {
//        Image(systemName: "forward.fill")
//    }
//    
//    Button(action: {
//        settings.selectedDate = Date()
//        log.info("Date updated to \(settings.selectedDate)")
//        fetchDataModel()
//    }) {
//        Image(systemName: "square.fill")
//    }
//}
//.frame(maxHeight: 30)
