//
//  ObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct ObservationsSpeciesView: View {
  let log = SwiftyBeaver.self


  @ObservedObject var observationsSpecies: ObservationsViewModel
  
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var speciesViewModel: SpeciesViewModel
  @EnvironmentObject var settings: Settings

  @EnvironmentObject var keyChainviewModel: KeychainViewModel

  @State private var hasAppeared = false
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0

  var item: Species

  @State private var offset = 0
  @State private var endOfListReached = false
  @State private var isLoaded = false

  @Binding var selectedSpeciesID: Int?


  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all


  var body: some View {
    VStack {
      VStack {
        if showView { Text("ObservationsSpeciesView").font(.customTiny) }

        HStack {
          // Image with accessibility label
          Image(systemSymbol: .circleFill)
            .foregroundColor(rarityColor(value: item.rarity))

          // Text with accessibility label
          Text("\(item.name)")
            .bold()
            .lineLimit(1) // Set the maximum number of lines to 1
            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated

          // Button with accessibility label and hint
//          Button(action: {
//            selectedSpeciesID = item.speciesId
//          }) {
//            Image(systemSymbol: .infoCircle)
//              .uniformSize()
//          }
//
//          Button(action: {
//            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.speciesId) {
//              bookMarksViewModel.removeRecord(speciesID: item.speciesId)
//            } else {
//              bookMarksViewModel.appendRecord(speciesID: item.speciesId)
//            }
//          }) {
//            Image(systemSymbol: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.speciesId) ? SFSpeciesFill : SFSpecies)
//              .uniformSize()
//          }
//          .accessibilityLabel(favoriteObserver)
//          .background(Color.clear)
          Spacer()
        }
      }
      .padding(.horizontal,10)
      .accessibilityElement(children: .combine)
      .accessibilityLabel(Text("\(item.name), \(item.rarity) \(information)"))
      Spacer()

      VStack {
        if let observations = observationsSpecies.observations, observations.count == 0 {
          Text(noObsLastPeriod)// \(item.name)")
            .font(.headline) // Set font style
            .foregroundColor(.secondary) // Adjust text color
            .multilineTextAlignment(.center) // Align text to the center
            .padding() // Add padding around the text
          Spacer()
        } else {

          if let observations = observationsSpecies.observations, observations.count > 0 {
            if showView { Text("ObservationListView").font(.customTiny) }

            HorizontalLine()
            ObservationListView(
              observations: observations,
              selectedSpeciesID: $selectedSpeciesID,
              timePeriod: $settings.timePeriodSpecies,
              entity: .species,
              currentSortingOption: $currentSortingOption,
              currentFilteringAllOption: $currentFilteringAllOption,
              currentFilteringOption: $currentFilteringOption
            ) {

              // Handle end of list event
              log.info("End of list reached in ParentView observationsSpecies")
              observationsSpecies.fetchData(
                settings: settings,
                url: observationsSpecies.next,
                token: keyChainviewModel.token,
                completion: {
                  log.error("observationUser.fetchData")
                })
            }
              .environmentObject(Settings()) // Pass environment object

          } else {
            NoObservationsView()
          }
        }
      }

      .refreshable {
        log.error("refreshing... observation species")
        fetchDataModel()
      }
      .onAppear() {
        if !hasAppeared {
          if settings.initialSpeciesLoad {
            fetchDataModel()
            settings.initialSpeciesLoad = false
          }
          hasAppeared = true // Prevent re-execution
        }
      }
    }
  }

  func fetchDataModel() {
    observationsSpecies.fetchDataInit(
      settings: settings,
      entity: .species,
      token: keyChainviewModel.token,
      id: item.speciesId,
      completion: {
        isLoaded = true
        log.info("observationsSpeciesViewModel data loaded")
      }
    )
  }
}

