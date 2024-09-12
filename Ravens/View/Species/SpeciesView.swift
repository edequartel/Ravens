//
//  TabSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct SpeciesView: View {
  @State private var showFirstView = false
  @State private var isPresented = false
  @State private var isPresented1 = false

  @EnvironmentObject var settings: Settings

  var item: Species
  @Binding var selectedSpecies: Species?

//  @Binding var selectedObservation: Observation?



  var body: some View {
    VStack {
      if showView { Text("SpeciesView").font(.customTiny) }
      if showFirstView && !settings.accessibility {
        MapObservationsSpeciesView(item: item)
      } else {
        ObservationsSpeciesView(
          item: item,
          selectedSpecies: $selectedSpecies
        )
      }
    }

    .toolbar {
      if !settings.accessibility {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFirstView.toggle()
          }) {
            Image(systemName: "rectangle.2.swap") // Replace with your desired image
          }
        }
      }

//      if !settings.accessibility {
//        ToolbarItem(placement: .navigationBarTrailing) {
//          Button(action: {
//            settings.hidePictures.toggle()
//          }) {
//            ImageWithOverlay(systemName: "photo", value: !settings.hidePictures)
//          }
//        }
//      }
    }
    .onAppear() {
      settings.initialSpeciesLoad = true
    }
  }
}



