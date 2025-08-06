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
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
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

  @Binding var timePeriod: TimePeriod?

  var body: some View {
    VStack {
      VStack {
        if showView { Text("ObservationsSpeciesView").font(.customTiny) }

        HStack {
          // Image with accessibility label
          Image(systemSymbol: .circleFill)
            .foregroundColor(rarityColor(value: item.rarity))

          // Text with accessibility label
          Text("\(item.name) \(item.speciesId)")
          //          Text("\(item.name) \(observationsSpecies.count)")
            .bold()
            .lineLimit(1) // Set the maximum number of lines to 1
            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
          Spacer()
        }
      }
      .padding(.horizontal, 10)
      .accessibilityElement(children: .combine)
      .accessibilityLabel(item.name)

      HStack {
        ObservationsCountView(count: observationsSpecies.count)
        Text("in")
          .font(.caption)
          .foregroundColor(.gray)
          .bold()
        ObservationsTimePeriodView(timePeriod: settings.timePeriodSpecies ?? .fourWeeks)
        Spacer()
      }
      .padding(.horizontal, 10)

      HorizontalLine()
      Spacer()

      if let observations = observationsSpecies.observations, !observations.isEmpty {
        if showView { Text("ObservationListView").font(.customTiny) }
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          timePeriod: $settings.timePeriodSpecies,
          entity: .species,
          currentSortingOption: $currentSortingOption,
          currentFilteringAllOption: $currentFilteringAllOption,
          currentFilteringOption: $currentFilteringOption
        ) {
          // Handle end of list event with endOfList Closure
          log.info("End of list reached in parent View closure observationsSpecies")
          log.info("url: \(observationsSpecies.next)")
          observationsSpecies.fetchData(
            settings: settings,
            url: observationsSpecies.next,
            token: keyChainviewModel.token,
            completion: {
              log.error("observationSpecies.fetchData")
            })
        }
        .environmentObject(Settings()) // Pass environment object

      } else {
        NoObservationsView()
      }
    }

    .onChange(of: settings.selectedSpeciesGroup) {
      print("xxx OBS HIER MOET HET NIET GEBEUREN xxx")
    }

    .onChange(of: timePeriod) {
      log.error("update timePeriodUser")

      observationsSpecies.fetchDataInit(
        settings: settings,
        entity: .species,
        token: keyChainviewModel.token,
        id: item.speciesId,
        speciesGroup: settings.selectedSpeciesGroup ?? 1, 
        timePeriod: settings.timePeriodSpecies,
        completion: {
          isLoaded = true
          log.error("observationsSpeciesViewModel data loaded")
        }
      )
    }

    .refreshable {
      log.error("refreshing... observation species")
      fetchDataModel()
    }

    .navigationBarTitleDisplayMode(.inline)

    .onAppear {
      if !hasAppeared {
        if settings.initialSpeciesLoad {
          fetchDataModel()
          settings.initialSpeciesLoad = false
        }
        hasAppeared = true // Prevent re-execution
      }
    }
  }

  func fetchDataModel() {
    observationsSpecies.fetchDataInit(
      settings: settings,
      entity: .species,
      token: keyChainviewModel.token,
      id: item.speciesId,
      speciesGroup: settings.selectedSpeciesGroup ?? 1, 
      timePeriod: settings.timePeriodSpecies,
      completion: {
        isLoaded = true
        log.info("observationsSpeciesViewModel data loaded")
      }
    )
  }
}

struct SelectedUserSpeciesView: View {
  let speciesGroup: String

  var body: some View {
    HStack {
      HStack {
        Text("\(speciesGroup)")
//        Text("\(speciesGroupsViewModel.speciesDictionary[settings.selectedRadiusSpeciesGroup ?? 0] ?? ""),")
      }
      .font(.caption)
      .foregroundColor(.gray)
      .bold()
//      .padding(.horizontal, 10)
//      Spacer()
    }
    .accessibilityElement(children: .combine)
  }
}

struct ObservationsCountView: View {
  let count: Int

  var body: some View {
    HStack {
      HStack {
        Text("\(count)")
        Text(observationsLocStr)
      }
      .font(.caption)
      .foregroundColor(.gray)
      .bold()
    }
    .accessibilityElement(children: .combine)
  }
}

struct ObservationsTimePeriodView: View {
  let timePeriod: TimePeriod

  var body: some View {
    HStack {
      HStack {
        Text(timePeriod.localized)
      }
      .font(.caption)
      .foregroundColor(.gray)
      .bold()
    }
    .accessibilityElement(children: .combine)
  }
}
