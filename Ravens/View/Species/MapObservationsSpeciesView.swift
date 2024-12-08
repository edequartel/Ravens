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
    @ObservedObject var observationsSpecies: ObservationsViewModel

//    @EnvironmentObject var observationsSpeciesViewModel: ObservationsViewModel
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
                UserAnnotation()

                ForEach(observationsSpecies.observations ?? []) { observation in
                    Annotation("", coordinate:  CLLocationCoordinate2D(
                      latitude: observation.point.coordinates[1],
                      longitude: observation.point.coordinates[0])) {
                        ObservationAnnotationView(observation: observation)
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
                       
                      Text("\((observationsSpecies.observations?.count ?? 0))x")
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
                .background(Color.obsGreenEagle.opacity(0.8))
            }
            .mapStyle(settings.mapStyle)
            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() //tapping this makes it north
            }
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
      observationsSpecies.fetchData(
            settings: settings,
            entity: .species,
            id: item.speciesId,
            completion: {
              log.info("MAPobservationsSpeciesView data loaded")
            }
        )
    }
}


//struct MapObservationsSpeciesView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Setting up the environment objects for the preview
//      let testSpecies = Species(speciesId: 62, name: "Unknown", scientificName: "Scientific name", rarity: 1, native: true, time: "00:00", date: "1900-01-01")
//        MapObservationsSpeciesView(item: testSpecies)
//            .environmentObject(Settings())
//            .environmentObject(KeychainViewModel())
//            .environmentObject(ObservationsViewModel())
//    }
//}
