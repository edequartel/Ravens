//
//  ObservationListView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/09/2024.
//

import SwiftUI

struct ObservationListView: View {
  var observations: [Observation]
  var entity: EntityType
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    List {
      ForEach(observations, id: \.id) { obs in
        VStack {
          NavigationLink(destination: ObsDetailView(obs: obs)) {
            ObsView(
              showSpecies: !(entity == .species),  //<--
              showObserver: !(entity == .user),
              showArea: !(entity == .area),
              selectedSpeciesID: $selectedSpeciesID,
              obs: obs
            )
            .padding(8)
          }
          .accessibilityLabel("\(obs.species_detail.name) \(obs.date) \(obs.time ?? "")")
          Divider()
        }
        .listRowInsets(EdgeInsets(top:0, leading:16, bottom:0, trailing:16)) // Remove default padding
        .listRowSeparator(.hidden)  // Remove separator line
      }
    }
    .listStyle(PlainListStyle()) // No additional styling, plain list look
    .toolbar {
      if (!settings.accessibility) {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
//            settings.hidePictures.toggle()
          }) {
            Image(systemName: "arrow.up.arrow.down")
//              .accessibilityElement(children: .combine)
              .accessibility(label: Text("Sorting"))
          }
        }
      }
    }
  }
}



//#Preview {
//  @State static var selectedObservation: Observation? = nil
//    ObservationListView(
//      observations: [selectedObservation],
//      entity: .area,
//      selectedSpeciesID: .constant(nil))
//}
