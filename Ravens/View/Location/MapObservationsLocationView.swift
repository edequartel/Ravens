
// File: Ravens/MapObservationsLocationView.swift

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

  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel

  @Binding var setLocation: CLLocationCoordinate2D

  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?

  var body: some View {
    VStack {
      HStack {
        Text("\(settings.locationName)")
          .bold()
        Spacer()
      }
      .padding(.horizontal, 10)

      HStack {
        let speciesGroupName = speciesGroupsViewModel.speciesDictionary[settings.selectedLocationSpeciesGroup ?? 0] ?? ""
        SelectedUserSpeciesView(speciesGroup: settings.selectedLocationSpeciesGroup != -1 ? speciesGroupName : "∞")
        ObservationsCountView(count: observationsLocation.count)
        Text("in")
          .font(.caption)
          .foregroundColor(.gray)
          .bold()
        ObservationsTimePeriodView(timePeriod: settings.timePeriodLocation ?? .fourWeeks)
        Spacer()
      }
      .padding(.horizontal, 10)
//      HorizontalLine()

      MapReader { proxy in
        Map(position: $settings.cameraAreaPosition) {
          UserAnnotation()

          // Areas
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
                    .fill(Color.red)
                )
            }
          }

          // Observations (filtered)
          let obs = observationsLocation.observations ?? []
          let filteredObs = obs.filter {
            $0.rarity == currentFilteringOption?.intValue ?? 0 || currentFilteringOption?.intValue ?? 0 == 0
          }

          ForEach(filteredObs) { observation in
            Annotation(observation.speciesDetail.name,
                       coordinate: CLLocationCoordinate2D(
                        latitude: observation.point.coordinates[1],
                        longitude: observation.point.coordinates[0])) {
              ObservationAnnotationView(observation: observation, entity: .location)
            }
          }

          // GeoJSON overlays
          ForEach(geoJSONViewModel.polyOverlays, id: \.self) { polyOverlay in
            MapPolygon(polyOverlay)
              .stroke(.pink, lineWidth: 1)
              .foregroundStyle(.blue.opacity(0.1))
          }
        }
        .mapStyle(settings.mapStyle)
        .mapControls {
          MapCompass() // north reset
        }
        // Use SpatialTapGesture to get tap location in view space and convert to geo coords.
        .simultaneousGesture(
          SpatialTapGesture()
            .onEnded { value in
//              print("okidoki") // ensure it fires on any map tap not hitting an annotation
              if let coordinate = proxy.convert(value.location, from: .local) {
                setLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
              }
            }
        )
        // Optional: long-press fallback when user is panning/zooming quickly.
//        .simultaneousGesture(
//          LongPressGesture(minimumDuration: 0.3)
//            .onEnded { _ in
//              // no-op; this keeps long-press available if you want to add behavior later
//            }
//        )
//        .safeAreaInset(edge: .bottom) {
//          VStack {
//            SettingsDetailsView()
//          }
//          .padding(5)
//          .frame(maxWidth: .infinity)
//          .foregroundColor(.obsGreenFlower)
//          .background(Color.obsGreenEagle.opacity(0.8))
//        }
      }
      .onAppear {
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
      longitude: geoJSONViewModel.span.longitude
    )

    let span = MKCoordinateSpan(
      latitudeDelta: geoJSONViewModel.span.latitudeDelta,
      longitudeDelta: geoJSONViewModel.span.longitudeDelta
    )

    let region = MKCoordinateRegion(center: center, span: span)
    return MapCameraPosition.region(region)
  }
}
////
////  MapObservationsLocationView.swift
////  Ravens
////
////  Created by Eric de Quartel on 26/03/2024.
////
//
//import SwiftUI
//import MapKit
//import SwiftyBeaver
//
//struct MapObservationsLocationView: View {
//  let log = SwiftyBeaver.self
//  @ObservedObject var observationsLocation: ObservationsViewModel
//  @ObservedObject var locationIdViewModel: LocationIdViewModel
//  @ObservedObject var geoJSONViewModel: GeoJSONViewModel
//
//  @EnvironmentObject var areasViewModel: AreasViewModel
//  @EnvironmentObject var locationManagerModel: LocationManagerModel
//  @EnvironmentObject var keyChainViewModel: KeychainViewModel
//  @EnvironmentObject var settings: Settings
//  @EnvironmentObject var poiViewModel: POIViewModel
//
//  @Binding var setLocation: CLLocationCoordinate2D
//
//  @Binding var currentFilteringAllOption: FilterAllOption?
//  @Binding var currentFilteringOption: FilteringRarityOption?
//  @Binding var timePeriod: TimePeriod? 
//
//  var body: some View {
//    VStack {
//      MapReader { proxy in
//        Map(position: $settings.cameraAreaPosition) {
//          UserAnnotation()
//          //
//          ForEach(areasViewModel.records, id: \.id) { record in
//            Annotation(record.name,
//                       coordinate: CLLocationCoordinate2D(
//                        latitude: record.latitude,
//                        longitude: record.longitude)) {
//                          Triangle()
//                            .fill(Color.gray)
//                            .frame(width: 10, height: 10)
//                            .overlay(
//                              Triangle()
//                                .stroke(Color.red, lineWidth: 1)
//                                .fill(Color.red)// Customize the border color and width
//                            )
//                        }
//          }
//
//          // location observations
//          // filter the observations
//          let obs = observationsLocation.observations ?? []
//          let filteredObs = obs.filter { $0.rarity == currentFilteringOption?.intValue ?? 0  || currentFilteringOption?.intValue ?? 0 == 0 }
//
//          ForEach(filteredObs) { observation in
//            Annotation(observation.speciesDetail.name,
//                       coordinate: CLLocationCoordinate2D(
//                        latitude: observation.point.coordinates[1],
//                        longitude: observation.point.coordinates[0])) {
//              ObservationAnnotationView(observation: observation)
//            }
//          }
//
//          // geoJSON
//          ForEach(geoJSONViewModel.polyOverlays, id: \.self) { polyOverlay in
//            MapPolygon(polyOverlay)
//              .stroke(.pink, lineWidth: 1)
//              .foregroundStyle(.blue.opacity(0.1))
//          }
//
//        }
//        .mapStyle(settings.mapStyle)
//        .mapControls {
//          MapCompass() // tapping this makes it north
//        }
//
//        //
//        .onTapGesture { position in
//          print("okidoki")
//          if let coordinate = proxy.convert(position, from: .local) {
//            setLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//          }
//        }
//
////        .safeAreaInset(edge: .bottom) {
////          VStack {
////            SettingsDetailsView()
////          }
////          .padding(5)
////          .frame(maxWidth: .infinity)
////          .foregroundColor(.obsGreenFlower)
////          .background(Color.obsGreenEagle.opacity(0.8))
////        }
//
//      }
//      .onAppear {
//        log.info("MapObservationsLocationView onAppear")
//
//      }
//    }
//  }
//
//  func colorByMapStyle() -> Color {
//    if settings.mapStyleChoice == .standard {
//      return Color.gray
//    } else {
//      return Color.white
//    }
//  }
//
//  func getCameraPosition() -> MapCameraPosition {
//    let center = CLLocationCoordinate2D(
//      latitude: geoJSONViewModel.span.latitude,
//      longitude: geoJSONViewModel.span.longitude)
//
//    let span = MKCoordinateSpan(
//      latitudeDelta: geoJSONViewModel.span.latitudeDelta,
//      longitudeDelta: geoJSONViewModel.span.longitudeDelta)
//
//    let region = MKCoordinateRegion(center: center, span: span)
//    return MapCameraPosition.region(region)
//  }
//}
