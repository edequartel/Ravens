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
  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject var locationManager: LocationManagerModel

  @EnvironmentObject var observationsUserViewModel: ObservationsViewModel


  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var userViewModel:  UserViewModel
  @EnvironmentObject var settings: Settings

  @State private var cameraPosition: MapCameraPosition = .automatic

  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045) // Default span
  )

  @State private var showObservers: Bool = false
  @State private var showListView: Bool = false

  var body: some View {

    ZStack(alignment: .topLeading) {
      Map(position: $cameraPosition) {
        UserAnnotation()
        ForEach(observationsUserViewModel.observations ?? []) { observation in
          Annotation(observation.speciesDetail.name,
                     coordinate:  CLLocationCoordinate2D(
                      latitude: observation.point.coordinates[1],
                      longitude: observation.point.coordinates[0]))
          {
            ObservationAnnotationView(observation: observation)
          }
        }
      }
      .mapStyle(settings.mapStyle)

      .mapControls() {
        MapUserLocationButton()
        MapPitchToggle()
        MapCompass() //tapping this makes it north
      }
    }
    .onAppear {
      updateRegionToUserLocation()
    }
  }

  private func updateRegionToUserLocation() {
    guard let userLocation = locationManager.getCurrentLocation() else {
      log.warning("User location not available")
      return
    }

    // Define 5x5 km span (latitudeDelta and longitudeDelta)
    let kilometersToDegrees = 255.0 / 111.0
    let updatedRegion = MKCoordinateRegion(
      center: userLocation.coordinate,
      span: MKCoordinateSpan(latitudeDelta: kilometersToDegrees, longitudeDelta: kilometersToDegrees)
    )

    region = updatedRegion
    cameraPosition = .region(updatedRegion) // Update camera to this region
  }
}

//struct MapObservationsUserView_Previews: PreviewProvider {
//  static var previews: some View {
//    MapObservationsUserView()
//      .environmentObject(ObservationsViewModel())
//      .environmentObject(KeychainViewModel())
//      .environmentObject(UserViewModel())
//      .environmentObject(Settings())
//  }
//}


import SwiftUI
import MapKit

struct ObservationAnnotationView: View {
  let observation: Observation

  var body: some View {
    Circle()
      .fill(rarityColor(value: observation.rarity))
      .stroke(!(observation.sounds?.isEmpty ?? false) ? Color.white : Color.clear, lineWidth: 1)
      .frame(width: 12, height: 12)
      .overlay(
        Circle()
          .fill(!(observation.photos?.isEmpty ?? false) ? Color.white : Color.clear)
          .frame(width: 6, height: 6)
      )
      .onTapGesture {
        print("Tapped observation \(observation.speciesDetail.name)")
      }
  }
}

//struct ObservationAnnotationView: View {
//    let observation: Observation
//    @State private var showPopup = false // Tracks the visibility of the popup
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(rarityColor(value: observation.rarity))
//                .stroke(!(observation.sounds?.isEmpty ?? false) ? Color.white : Color.clear, lineWidth: 1)
//                .frame(width: 12, height: 12)
//                .overlay(
//                    Circle()
//                        .fill(!(observation.photos?.isEmpty ?? false) ? Color.white : Color.clear)
//                        .frame(width: 6, height: 6)
//                )
//                .onTapGesture {
//                    showPopup.toggle() // Toggles the popup visibility
//                }
//
//            // Popup View
//            if showPopup {
//                VStack {
//                    Text("\(observation.speciesDetail.name)")
//                        .font(.headline)
//
//                    Button(action: {
//                        showPopup = false // Dismiss the popup
//                    }) {
//                        Text("Close")
//                            .font(.subheadline)
//                            .foregroundColor(.blue)
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(10)
//                .shadow(radius: 10)
//                .frame(width: 300)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//                .offset(y: -60) // Adjust the position of the popup
//                .transition(.opacity) // Optional animation
//            }
//        }
//    }
//}
