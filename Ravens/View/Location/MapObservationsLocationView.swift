//
//  MapObservationsLocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 26/03/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver


struct MapObservationsLocationView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var locationIdViewModel: LocationIdViewModel
  @ObservedObject var geoJSONViewModel: GeoJSONViewModel

  @EnvironmentObject var areasViewModel: AreasViewModel
  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var poiViewModel: POIViewModel

  var body: some View {
    VStack {
      MapReader { proxy in
        Map(position: $settings.cameraAreaPosition) {
          UserAnnotation()
          //
          ForEach(areasViewModel.records, id: \.id) { record in
            Annotation(record.name,
                       coordinate: CLLocationCoordinate2D(
                        latitude: record.latitude,
                        longitude: record.longitude)) {
                          Triangle()
                            .fill(Color.gray)
                            .frame(width: 10, height: 10)
                            .overlay(
                              Triangle()
                                .stroke(Color.red, lineWidth: 1)
                                .fill(Color.red)// Customize the border color and width
                            )
                        }
          }
          //
          // location observations
          ForEach(observationsLocation.observations ?? []) { observation in
            Annotation(observation.speciesDetail.name,
                       coordinate:  CLLocationCoordinate2D(
                        latitude: observation.point.coordinates[1],
                        longitude: observation.point.coordinates[0]))
            {
              ObservationAnnotationView(observation: observation)
            }
          }
          // geoJSON
          ForEach(geoJSONViewModel.polyOverlays, id: \.self) { polyOverlay in
            MapPolygon(polyOverlay)
              .stroke(.pink, lineWidth: 1)
              .foregroundStyle(.blue.opacity(0.1))
          }

        }
        .mapStyle(settings.mapStyle)
        .mapControls() {
          MapCompass() //tapping this makes it north
        }
        .safeAreaInset(edge: .bottom) {
          VStack {
            SettingsDetailsView()
          }
          .padding(5)
          .frame(maxWidth: .infinity)
          .foregroundColor(.obsGreenFlower)
          .background(Color.obsGreenEagle.opacity(0.8))
        }
        .onTapGesture() { position in
          if let coordinate = proxy.convert(position, from: .local) {
            fetchDataLocation(
              settings: settings,
              token: keyChainViewModel.token,
              observationsLocation: observationsLocation,
              locationIdViewModel: locationIdViewModel,
              geoJSONViewModel: geoJSONViewModel,
              coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
          }
        }
      }
      .onAppear() {
        log.info("MapObservationsLocationView onAppear")
      }
    }
  }

  func colorByMapStyle() -> Color {
    if settings.mapStyleChoice == .standard {
      return Color.gray
    } else {
      return Color.white
    }
  }

  func getCameraPosition() -> MapCameraPosition {
    let center = CLLocationCoordinate2D(
      latitude: geoJSONViewModel.span.latitude,
      longitude: geoJSONViewModel.span.longitude)

    let span = MKCoordinateSpan(
      latitudeDelta: geoJSONViewModel.span.latitudeDelta,
      longitudeDelta: geoJSONViewModel.span.longitudeDelta)


    let region = MKCoordinateRegion(center: center, span: span)
    return MapCameraPosition.region(region)
  }
}


//struct MapObservationLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Setting up the environment objects for the preview
//        MapObservationsLocationView()
//            .environmentObject(Settings())
//            .environmentObject(ObservationsRadiusViewModel())
////            .environmentObject(SpeciesGroupViewModel())
//            .environmentObject(KeychainViewModel())
//
//    }
//}


