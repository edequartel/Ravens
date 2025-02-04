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
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var settings: Settings

  @State private var once: Bool = false

  @Binding var selectedSpeciesID: Int?
  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?
  @Binding var region: MKCoordinateRegion
  @Binding var cameraPosition: MapCameraPosition

  var body: some View {
    VStack {
      if let observations = observationsRadiusViewModel.observations, !observations.isEmpty {
        HorizontalLine()
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          timePeriod: $settings.timePeriodUser,
          entity: .radius,
          currentSortingOption: $currentSortingOption,
          currentFilteringAllOption: $currentFilteringAllOption,
          currentFilteringOption: $currentFilteringOption
        )
      } else {
        NoObservationsView()
      }
    }
    .onAppear {
      if !observationsRadiusViewModel.hasLoadedData {
        log.error("radiusView onAppearOnce")
        observationsRadiusViewModel.circleCenter = locationManager.getCurrentLocation()?.coordinate ?? CLLocationCoordinate2D(latitude: 54.0, longitude: 6.0)
        observationsRadiusViewModel.fetchData(
          settings: settings,
          latitude: observationsRadiusViewModel.circleCenter.latitude,
          longitude: observationsRadiusViewModel.circleCenter.longitude,
          radius: circleRadius,
          timePeriod: timePeriod ?? .fourWeeks)
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

struct RadiusMapView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var locationManager: LocationManagerModel

  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?
  @Binding var region: MKCoordinateRegion
  @Binding var cameraPosition: MapCameraPosition

  var body: some View {
    MapReader { proxy in
      Map(position: $cameraPosition) {
        UserAnnotation()

        //observations
        let obs = observationsRadiusViewModel.observations ?? []
        let filteredObs = obs.filter {
          $0.rarity == currentFilteringOption?.intValue ?? 0  || currentFilteringOption?.intValue ?? 0 == 0
        }
        ForEach(filteredObs) { observation in
          Annotation(observation.speciesDetail.name, coordinate:  CLLocationCoordinate2D(
            latitude: observation.point.coordinates[1],
            longitude: observation.point.coordinates[0])) {
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
            settings: settings,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: circleRadius,
            timePeriod: timePeriod ?? .fourWeeks,
            completion: {
              log.error("tapgesture update userlocation")
              updateRegionToUserLocation(coordinate: coordinate)
            })
        }
      }
    }
    .onAppear {
      log.error("radiusMapView onAppear")
      updateRegionToUserLocation(coordinate: observationsRadiusViewModel.circleCenter)
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
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel
  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject private var settings: Settings

  @Binding var selectedSpeciesID: Int?

  @State private var showFirstView = false
  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all
  @State private var timePeriod: TimePeriod? = .twoWeeks
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045) // Default span
  )

  @State private var cameraPosition: MapCameraPosition = .automatic

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("TabRadiusView").font(.customTiny) }

        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          RadiusMapView(observationsRadiusViewModel: observationsRadiusViewModel,
                        currentSortingOption: $currentSortingOption,
                        currentFilteringAllOption: $currentFilteringAllOption,
                        currentFilteringOption: $currentFilteringOption,
                        timePeriod: $timePeriod,
                        region: $region,
                        cameraPosition: $cameraPosition)
        } else {
          RadiusListView(observationsRadiusViewModel: observationsRadiusViewModel,
                         selectedSpeciesID: $selectedSpeciesID,
                         currentSortingOption: $currentSortingOption,
                         currentFilteringAllOption: $currentFilteringAllOption,
                         currentFilteringOption: $currentFilteringOption,
                         timePeriod: $timePeriod,
                         region: $region,
                         cameraPosition: $cameraPosition
          )
        }
      }


      .modifier(
        showFirstView ?
        ObservationToolbarModifier(
          currentFilteringOption: $currentFilteringOption,
//          timePeriod: $timePeriod,
          entity: .radius)
        :
          ObservationToolbarModifier(
            currentFilteringOption: $currentFilteringOption,
            timePeriod: $timePeriod,
            entity: .radius)
      )

      .onChange(of: timePeriod) {//!!
        log.error("update timePeriod \(String(describing: timePeriod))")
        observationsRadiusViewModel.observations = []


        //get the location which is onTappedbefore!!
//        observationsRadiusViewModel.circleCenter

//        if let location = locationManager.getCurrentLocation() {
//          observationsRadiusViewModel.circleCenter = location.coordinate

          observationsRadiusViewModel.fetchData(
            settings: settings,

            latitude: observationsRadiusViewModel.circleCenter.latitude,
            longitude: observationsRadiusViewModel.circleCenter.longitude,

//            latitude: location.coordinate.latitude,
//            longitude: location.coordinate.longitude,

            radius: circleRadius, //circleRadius,
            timePeriod: timePeriod ?? .fourWeeks,
            completion: {
              log.error("update timePeriod")
            })
//        }
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


        }


        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            observationsRadiusViewModel.observations = []

            if let location = locationManager.getCurrentLocation() {
              observationsRadiusViewModel.circleCenter = location.coordinate

              observationsRadiusViewModel.fetchData(
                settings: settings,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radius: circleRadius, //circleRadius,
                timePeriod: timePeriod ?? .fourWeeks,
                completion: {
                  log.error("tapgesture update userlocation")
                  updateRegionToUserLocation(coordinate: location.coordinate)
                })
            }


          }) {
            Image(systemName: "smallcircle.filled.circle")
              .uniformSize()
              .accessibilityLabel(updateLocation)
          }
        }
      }
    }
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
//
//#Preview {
//    RadiusView()
//}
