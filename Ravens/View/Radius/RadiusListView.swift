//
//  RadiusListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 02/04/2025.
//

import SwiftUI
import Foundation
import Alamofire
import Combine
import SwiftyBeaver
import MapKit

struct RadiusListView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel

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
      if showView { Text("RadiusListView").font(.customTiny) }

      HStack {
        let speciesGroupName = speciesGroupsViewModel.speciesDictionary[settings.selectedRadiusSpeciesGroup ?? 0] ?? ""
        SelectedUserSpeciesView(speciesGroup: settings.selectedRadiusSpeciesGroup != -1 ? speciesGroupName : "∞")
        ObservationsCountView(count: observationsRadiusViewModel.count)
        Text("in")
          .font(.caption)
          .foregroundColor(.gray)
          .bold()
        ObservationsTimePeriodView(timePeriod: settings.timePeriodRadius ?? .fourWeeks)
        Spacer()
      }
      .padding(.horizontal, 10)

      HorizontalLine()

      if let observations = observationsRadiusViewModel.observations, !observations.isEmpty {
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          
          timePeriod: $settings.timePeriodRadius,
          entity: .radius,
          currentSortingOption: $currentSortingOption,
          currentFilteringAllOption: $currentFilteringAllOption,
          currentFilteringOption: $currentFilteringOption
        ) {
          log.error("end of radiuslist")
          observationsRadiusViewModel.fetchData(
            settings: settings,
            url: observationsRadiusViewModel.next,
            completion: {
              log.error("radius count: \(observationsRadiusViewModel.count)")
            })
        }
      } else {
        NoObservationsView()
      }
    }
    .onAppear {
      if !observationsRadiusViewModel.hasLoadedData {
        log.info("radiusView onAppearOnce")
        observationsRadiusViewModel.circleCenter = locationManager.getCurrentLocation()?.coordinate ?? CLLocationCoordinate2D(latitude: 54.0, longitude: 6.0)
        observationsRadiusViewModel.fetchDataInit(
          settings: settings,
          latitude: observationsRadiusViewModel.circleCenter.latitude,
          longitude: observationsRadiusViewModel.circleCenter.longitude,
          radius: settings.radius,
          speciesGroup: settings.selectedRadiusSpeciesGroup ?? 1, 
          timePeriod: settings.timePeriodRadius,
          completion: {
            log.error("radiusView count \(observationsRadiusViewModel.count)")
          })
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
