//  Accessible
//  SwiftUIView.swift
//  Ravens
//
//  Created by Eric de Quartel on 30/09/2024.
//

import SwiftUI
import SFSafeSymbols

struct ShareLinkButtonView: View {
    var obs: Observation
    var body: some View {
        let url = URL(string: obs.permalink)!
        ShareLink(item: url) {
            Image(systemSymbol: SFShareLink)
            .uniformSize()
        }
        .tint(.obsShareLink)
        .accessibilityLabel(shareThisObservation)
    }
}

struct URLButtonView: View {
  var url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
              UIApplication.shared.open(url)

            }
        }) {
          Image(systemSymbol: .clock)
            .uniformSize()
        }
        .tint(.obsObservation)
        .accessibilityLabel(linkObservation)
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
            Image(systemSymbol: SFObservation)
            .uniformSize()
        }
        .tint(.obsObservation)
        .accessibilityLabel(linkObservation)
    }
}

struct URLShareButtonView: View {
  var urlShare: String

  var body: some View {
      let url = URL(string: urlShare)!
      ShareLink(item: url) {
          Image(systemSymbol: SFShareLink)
          .uniformSize()
      }
//      .tint(.obsInformation)
      .accessibilityLabel(shareThisObservation)
  }
}

struct InformationSpeciesButtonView: View {
    @Binding var selectedSpeciesID: Int?
    var obs: Observation

    var body: some View {
        Button(action: {
            selectedSpeciesID = obs.speciesDetail.id
        }) {
            Image(systemSymbol: SFInformation)
        }
        .tint(.obsInformation)
        .accessibilityLabel(informationSpecies)
    }
}

struct AreaButtonView: View {
  @EnvironmentObject var areasViewModel: AreasViewModel
  var obs: Observation

  var body: some View {
    Button(action: {
      if areasViewModel.isIDInRecords(areaID: obs.locationDetail?.id ?? 0) {
        print("remove areas \(obs.locationDetail?.id ?? 0)")
        areasViewModel.removeRecord(
          areaID: obs.locationDetail?.id ?? 0)
      } else {
        print("adding area \(obs.locationDetail?.id ?? 0)")
        areasViewModel.appendRecord(
          areaName: obs.locationDetail?.name ?? "unknown",
          areaID: obs.locationDetail?.id ?? 0,
          latitude: obs.point.coordinates[1], 
          longitude: obs.point.coordinates[0]
        )
      }
    }) {
//      if areasViewModel.isIDInRecords(areaID: obs.locationDetail?.id ?? 0) {
        Image(systemSymbol: SFAreaFill)
          .uniformSize()
//      } else {
//        Image(systemSymbol: SFArea)
//          .uniformSize()
//      }
    }
    .accessibilityLabel(areasViewModel.isIDInRecords(areaID: obs.locationDetail?.id ?? 0) ? favoriteLocationOn : favoriteLocationOff)
  }
}

struct ObserversButtonView: View {
  @EnvironmentObject var observersViewModel: ObserversViewModel
  var obs: Observation

  var body: some View {
    Button(action: {
      if observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) {
        observersViewModel.removeRecord(userID: obs.userDetail?.id ?? 0)
      } else {
        observersViewModel.appendRecord(
          name: obs.userDetail?.name ?? "unknown",
          userID: obs.userDetail?.id ?? 0)
      }
    }) {
//      if observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) {
        Image(systemSymbol: SFObserverFill)
          .uniformSize()
//      } else {
//        Image(systemSymbol: SFObserver)
//          .uniformSize()
//      }
    }
    .accessibilityLabel(observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) ? favoriteObserverOn : favoriteObserverOff)
  }
}

struct BookmarkButtonView: View {
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  var speciesID: Int

  var body: some View {
    Button(action: {
      if bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) {
        bookMarksViewModel.removeRecord(speciesID: speciesID)
      } else {
        bookMarksViewModel.appendRecord(speciesID: speciesID)
      }
    }) {

//      Image(systemSymbol: bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) ? SFSpeciesFill : SFSpecies)
      Image(systemSymbol: SFSpeciesFill)
        .uniformSize()
    }
    .accessibilityLabel(bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) ? favoriteSpeciesOn : favoriteSpeciesOff)
    .background(Color.clear)
  }
}

struct BookmarkButtonView_Previews: PreviewProvider {
  static var previews: some View {
    // Create a mock BookMarksViewModel
    let mockBookMarksViewModel = BookMarksViewModel(fileName: "bookmarks.json")

    // Return the BookmarkButtonView with the mock data
    BookmarkButtonView(speciesID: 100)//obs: mockObservation, colorOn: true)
      .environmentObject(mockBookMarksViewModel)
  }
}

