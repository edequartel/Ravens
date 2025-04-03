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

    var body: some View {
        ZStack(alignment: .leading) {
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(observationsSpecies.observations ?? []) { observation in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                      latitude: observation.point.coordinates[1],
                      longitude: observation.point.coordinates[0])) {
                        ObservationAnnotationView(observation: observation)
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
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() // tapping this makes it north
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE dd-MM"
        return formatter
    }
}
