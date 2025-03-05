//
//  TabSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct SpeciesView: View {
  @State private var showFirstView = false

  @ObservedObject var observationsSpecies: ObservationsViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel

  var item: Species
  @Binding var selectedSpeciesID: Int?

  var body: some View {
    VStack {
      if showView { Text("SpeciesView").font(.customTiny) }
      if showFirstView && !accessibilityManager.isVoiceOverEnabled {
        MapObservationsSpeciesView(
          observationsSpecies: observationsSpecies,
          item: item)
      } else {
        ObservationsSpeciesView(
          observationsSpecies: observationsSpecies,
          item: item,
          selectedSpeciesID: $selectedSpeciesID
        )
      }
    }

    .toolbar {
      if !accessibilityManager.isVoiceOverEnabled {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFirstView.toggle()
          }) {
            Image(systemSymbol: .rectangle2Swap) // Replace with your desired image
              .uniformSize()
          }
          .accessibility(label: Text(switchView)) //??
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            selectedSpeciesID = item.speciesId
          }) {
            Image(systemSymbol: .infoCircle)
              .uniformSize()
          }
          .background(Color.clear)
        }


        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.speciesId) {
              bookMarksViewModel.removeRecord(speciesID: item.speciesId)
            } else {
              bookMarksViewModel.appendRecord(speciesID: item.speciesId)
            }
          }) {
            Image(systemSymbol: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.speciesId) ? SFSpeciesFill : SFSpecies)
              .uniformSize()
          }
          .accessibilityLabel(favoriteObserver)
          .background(Color.clear)
        }
      }

//      ToolbarItem(action: {
//        if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.speciesId) {
//          bookMarksViewModel.removeRecord(speciesID: item.speciesId)
//        } else {
//          bookMarksViewModel.appendRecord(speciesID: item.speciesId)
//        }
//      }) {
//        Image(systemSymbol: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.speciesId) ? SFSpeciesFill : SFSpecies)
//          .uniformSize()
//      }
//      .accessibilityLabel(favoriteObserver)
//      .background(Color.clear)

    }
    .onAppear() {
      settings.initialSpeciesLoad = true
    }
  }
}



