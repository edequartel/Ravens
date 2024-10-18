//
//  SwiftUIView.swift
//  Ravens
//
//  Created by Eric de Quartel on 30/09/2024.
//

import SwiftUI

struct ShareLinkButtonView: View {
    var obs: Observation
    var body: some View {
        let url = URL(string: obs.permalink)!
        ShareLink(item: url) {
            Image(systemName: SFShareLink)
        }
        .tint(.obsShareLink)
        .accessibility(label: Text("Share observation"))
    }
}

struct LinkButtonView: View {
    var obs: Observation
  
    var body: some View {
        Button(action: {
            if let url = URL(string: obs.permalink) {
              UIApplication.shared.open(url)
            }
        }) {
            Image(systemName: SFObservation)
        }
        .tint(.obsObservation)
        .accessibility(label: Text("Link to waarneming observation"))
    }
}

struct InformationSpeciesButtonView: View {
    @Binding var selectedSpeciesID: Int?
    var obs: Observation

    var body: some View {
        Button(action: {
            selectedSpeciesID = obs.species_detail.id
        }) {
            Image(systemName: SFInformation)
        }
        .tint(.obsInformation)
        .accessibility(label: Text("Information species"))
    }
}

struct AreaButtonView: View {
  @EnvironmentObject var areasViewModel: AreasViewModel
  var obs: Observation

  var body: some View {
    Button(action: {
      if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
        print("remove areas \(obs.location_detail?.id ?? 0)")
        areasViewModel.removeRecord(
          areaID: obs.location_detail?.id ?? 0)
      } else {
        print("adding area \(obs.location_detail?.id ?? 0)")
        areasViewModel.appendRecord(
          areaName: obs.location_detail?.name ?? "unknown",
          areaID: obs.location_detail?.id ?? 0,
          latitude: obs.point.coordinates[1], //!!?
          longitude: obs.point.coordinates[0]
        )
      }
    }) {
      if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
        Image(systemName: SFAreaFill)
      } else {
        Image(systemName: SFArea)
      }
    }
    .tint(.obsArea)
    .accessibility(label: Text("Add area"))
  }
}

struct ObserversButtonView: View {
  @EnvironmentObject var observersViewModel: ObserversViewModel
  var obs: Observation

  var body: some View {
    Button(action: {
      if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
        observersViewModel.removeRecord(userID: obs.user_detail?.id ?? 0)
      } else {
        observersViewModel.appendRecord(
          name: obs.user_detail?.name ?? "unknown",
          userID: obs.user_detail?.id ?? 0)
      }
    }) {
      if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
        Image(systemName: SFObserverFill)
      } else {
        Image(systemName: SFObserver)
      }
    }
    .tint(.obsObserver)
    .accessibility(label: Text("Add observer"))
  }
}

struct BookmarkButtonView: View {
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  var obs: Observation

  var body: some View {
    Button(action: {
      if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
        bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
      } else {
        bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
      }
    }) {
      Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) ? SFSpeciesFill : SFSpecies)
    }
    .tint(.obsBookmark)
    .accessibility(label: Text("Add bookmark"))
  }
}

struct BookmarkButtonView_Previews: PreviewProvider {
  static var previews: some View {
    // Create a mock BookMarksViewModel
    let mockBookMarksViewModel = BookMarksViewModel()

    // Return the BookmarkButtonView with the mock data
    BookmarkButtonView(obs: mockObservation)
      .environmentObject(mockBookMarksViewModel)
  }
}

