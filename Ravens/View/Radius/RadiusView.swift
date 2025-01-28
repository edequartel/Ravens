//
//  RadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import Foundation
import Alamofire
import Combine
import Foundation
import SwiftyBeaver
import MapKit

struct RadiusListView: View {
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  let circleRadius: CLLocationDistance = 1000.0 // Radius in meters

  @State private var once: Bool = false

  var body: some View {
    NavigationView {
      List(observationsRadiusViewModel.observations ?? [], id: \.id) { observation in
        ObservationRowView(
         obs: observation,
         selectedSpeciesID: $selectedSpeciesID,
         entity: .radius)

//            .accessibilityFocused($focusedItemID, equals: obs.idObs)
//            .onChange(of: focusedItemID) { newFocusID, oldFocusID in
//                handleFocusChange(newFocusID, from: filteredAndSortedObservations)
//            }
//            .onAppear {
//                if obs == filteredAndSortedObservations.last {
//                    print("end of list reached")
//                    onEndOfList?()
//                }
//            }
      }
      .listStyle(PlainListStyle()) // No additional styling, plain list look
//      .navigationTitle(obsAroundPoint)
      .navigationBarTitleDisplayMode(.inline)

      .onAppear {
        if !observationsRadiusViewModel.hasLoadedData {
          print("radiusView onAppearOnce")
          observationsRadiusViewModel.circleCenter = locationManager.getCurrentLocation()?.coordinate ?? CLLocationCoordinate2D(latitude: 54.0, longitude: 6.0)
          observationsRadiusViewModel.fetchData(
            latitude: observationsRadiusViewModel.circleCenter.latitude,
            longitude: observationsRadiusViewModel.circleCenter.longitude,
            radius: circleRadius)
          observationsRadiusViewModel.hasLoadedData = true
        }
      }

      .alert(item: $observationsRadiusViewModel.errorMessage) { errorMessage in
        Alert(
          title: Text("Error"),
          message: Text(errorMessage),
          dismissButton: .default(Text("OK"))
        )
      }
    }
  }
}

struct RadiusMapView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var locationManager: LocationManagerModel

  @State private var cameraPosition: MapCameraPosition = .automatic
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045) // Default span
  )

  let circleRadius: CLLocationDistance = 1000.0 // Radius in meters

  var body: some View {
    ZStack(alignment: .leading) {
      MapReader { proxy in
        Map(position: $cameraPosition) {
          UserAnnotation()

          ForEach(observationsRadiusViewModel.observations ?? []) { observation in
            Annotation("", coordinate:  CLLocationCoordinate2D(
              latitude: observation.point.coordinates[1],
              longitude: observation.point.coordinates[0])) {
                ObservationAnnotationView(observation: observation)
              }
          }

          // location observations
          ForEach(observationsRadiusViewModel.observations ?? []) { observation in
            Annotation(observation.speciesDetail.name,
                       coordinate:  CLLocationCoordinate2D(
                        latitude: observation.point.coordinates[1],
                        longitude: observation.point.coordinates[0]))
            {
              ObservationAnnotationView(observation: observation)
            }
          }

          MapCircle(
            center: CLLocationCoordinate2D(
                latitude: observationsRadiusViewModel.circleCenter.latitude,
                longitude: observationsRadiusViewModel.circleCenter.longitude),
            radius: circleRadius)
          .foregroundStyle(.blue.opacity(0.2)) // Fill the circle with blue color
          .stroke(.blue.opacity(0.7), lineWidth: 1) // Add a border



        }
        .mapStyle(settings.mapStyle)
        .mapControls() {
          MapUserLocationButton()
          MapPitchToggle()
          MapCompass() //tapping this makes it north
        }

        .onTapGesture() { position in
          observationsRadiusViewModel.observations = []

          if let coordinate = proxy.convert(position, from: .local) {
            observationsRadiusViewModel.circleCenter = coordinate

            observationsRadiusViewModel.fetchData(
              latitude: coordinate.latitude,
              longitude: coordinate.longitude,
              radius: circleRadius,
              completion: {
                print("yyy")
                updateRegionToUserLocation(coordinate: coordinate)
              })
          }
        }
      }
          .onAppear {
            print("radiusMapView onAppear")
            updateRegionToUserLocation(coordinate: observationsRadiusViewModel.circleCenter)
          }
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EE dd-MM"
    return formatter
  }

  private func updateRegionToUserLocation(coordinate: CLLocationCoordinate2D) {

    log.error("User location IS available")
    // Define area span (latitudeDelta and longitudeDelta)
    let updatedRegion = MKCoordinateRegion(
      center: coordinate,
      span: MKCoordinateSpan(
        latitudeDelta: circleRadius / 20000,
        longitudeDelta: circleRadius / 20000)
    )

    region = updatedRegion
    cameraPosition = .region(updatedRegion) // Update camera to this region
  }
}


struct TabRadiusView: View {
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel
  @State private var showFirstView = false
  @Binding var selectedSpeciesID: Int?


  var body: some View {
    NavigationView {
      VStack {
        if showFirstView {
          RadiusMapView(observationsRadiusViewModel: observationsRadiusViewModel)
        } else {
          RadiusListView(observationsRadiusViewModel: observationsRadiusViewModel,
          selectedSpeciesID: $selectedSpeciesID)
        }
      }

      .toolbar {
        //map or list
        //      if !accessibilityManager.isVoiceOverEnabled {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            showFirstView.toggle()
          }) {
            Image(systemName: "rectangle.2.swap")
              .uniformSize()
              .accessibilityLabel(toggleViewMapList)
          }
          //        }
        }
      }
    }
  }
}
//
//#Preview {
//    RadiusView()
//}
