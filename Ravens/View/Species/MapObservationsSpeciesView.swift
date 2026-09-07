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

    @EnvironmentObject var settings: Settings
    
    var item: Species
    
    @State private var limit = 100
    @State private var offset = 0
    @State private var showFullScreenMap = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 52.0, longitude: 5.0),
      span: MKCoordinateSpan(latitudeDelta: 4.5, longitudeDelta: 3.0)
    )

    var body: some View {
        ZStack(alignment: .leading) {
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(observationsSpecies.observations ?? []) { observation in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                      latitude: observation.point.coordinates[1],
                      longitude: observation.point.coordinates[0])) {
                        ObservationAnnotationView(observation: observation, entity: .species)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
              VStack {
                Text("\(item.name)")
                  .lineLimit(1) // Set the maximum number of lines to 1
                  .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
              }
              .padding(5)
              .frame(maxWidth: .infinity)
              .foregroundColor(.obsGreenFlower)
              .background(Color.obsGreenEagle.opacity(0.8))
            }
            .mapStyle(settings.mapStyle)
            .mapControls {
                MapCompass() // tapping this makes it north
            }
            .onMapCameraChange { context in
                region = context.region
            }
            .overlay(alignment: .topTrailing) {
                MapControlButtons(cameraPosition: $cameraPosition, region: $region)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE dd-MM"
        return formatter
    }
}
