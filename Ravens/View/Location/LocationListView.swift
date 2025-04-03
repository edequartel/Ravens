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

  @Binding var setLocation: CLLocationCoordinate2D //for the onchange in TabLocationView to update
  @State private var locationID: Int = 0

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("LocationListView").font(.customTiny) }

        List {
          ForEach(areasViewModel.records.sorted { $0.name < $1.name }) { record in
            HStack {
              Button(action: {

                settings.locationName = record.name
                settings.locationId = record.areaID
                setLocation.latitude = record.latitude
                setLocation.longitude = record.longitude
                
                self.presentationMode.wrappedValue.dismiss()
              }) {
                HStack {
                  Text(record.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                  Spacer()
                  if (record.areaID == settings.locationId) {
                    Image(systemName: "checkmark").foregroundColor(.blue)
                  }
                }
              }
            }
            .padding(.vertical, 4)
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
    }

    .toolbar { //deze werkt niet goed en is misschien onnodig
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(
          destination: SearchLocationView(
            setLocation: $setLocation,
            locationID: $locationID
          )) {
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
