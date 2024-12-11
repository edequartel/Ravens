//
//  LocationListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/12/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct LocationListView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var locationIdViewModel: LocationIdViewModel
  @ObservedObject var geoJSONViewModel: GeoJSONViewModel

  @EnvironmentObject private var areasViewModel: AreasViewModel
  @EnvironmentObject private var settings: Settings

  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  var body: some View {
    VStack {
      List {
        ForEach(areasViewModel.records.sorted { $0.name < $1.name }) { record in
          HStack {
            Button(action: {
              settings.locationName = record.name
              settings.locationId = record.areaID

              fetchDataLocation(
                settings: settings,
                observationsLocation: observationsLocation,
                locationIdViewModel: locationIdViewModel,
                geoJSONViewModel: geoJSONViewModel,
                coordinate: CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude))

              self.presentationMode.wrappedValue.dismiss()
            }) {
              Text(record.name)
                .lineLimit(1)
            }
            Spacer()
          }
          .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
              areasViewModel.removeRecord(areaID: record.areaID)
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(destination: SearchLocationView()) {
          Image(systemSymbol: .magnifyingglass)
            .uniformSize()
            .accessibilityLabel(searchForLocation)
        }
      }
    }
    .onAppear {
      areasViewModel.loadRecords()
    }
  }
}
