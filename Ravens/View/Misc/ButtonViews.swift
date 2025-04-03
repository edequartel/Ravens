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
//      .tint(.blue)
      .accessibilityLabel(shareThisObservation)
  }
}

struct InformationSpeciesButtonView: View {
    @Binding var selectedSpeciesID: Int?
    var obs: Observation

    var body: some View {
      NavigationLink(destination: SpeciesDetailsView(speciesID: obs.speciesDetail.id)) {
        Image(systemSymbol: .infoCircle)
                .uniformSize()
        }
        .tint(.blue)
        .accessibilityLabel(informationSpecies)

//        Button(action: {
//            selectedSpeciesID = obs.speciesDetail.id
//        }) {
//            Image(systemSymbol: SFInformation)
//        }
//        .tint(.blue) 
//        .accessibilityLabel(informationSpecies)
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
        Image(systemSymbol: areasViewModel.isIDInRecords(areaID: obs.locationDetail?.id ?? 0) ? SFAreaFill: SFArea)
          .uniformSize()
    }
    .accessibilityLabel(areasViewModel.isIDInRecords(areaID: obs.locationDetail?.id ?? 0) ? favoriteLocationOn : favoriteLocationOff)
  }
}

struct AreaLocationButtonView: View {
  @EnvironmentObject var areasViewModel: AreasViewModel
  @EnvironmentObject private var settings: Settings
  
//  var locationDetail: LocationDetail?
//  var locationPoint: Point?

  var body: some View {
    Button(action: {
      if areasViewModel.isIDInRecords(areaID: settings.locationId) {
        print("remove areas \(settings.locationId)")
        areasViewModel.removeRecord(
          areaID: settings.locationId)
      } else {
        print("adding area \(settings.locationId)")
        areasViewModel.appendRecord(
          areaName: settings.locationName,
          areaID: settings.locationId,
          latitude: settings.locationCoordinate?.latitude ?? 0,
          longitude: settings.locationCoordinate?.longitude ?? 0
        )
      }
    }) {
        Image(systemSymbol: areasViewModel.isIDInRecords(areaID: settings.locationId) ? SFAreaFill: SFArea)
          .uniformSize()
    }
    .accessibilityLabel(areasViewModel.isIDInRecords(areaID: settings.locationId) ? favoriteLocationOn : favoriteLocationOff)
  }
}

struct ObserversObsButtonView: View {
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
      Image(systemSymbol: observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) ? SFObserverFill : SFObserver)
        .uniformSize()
    }
    .accessibilityLabel(observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) ? favoriteObserverOn : favoriteObserverOff)
  }
}

struct ObserversButtonView: View {
  @EnvironmentObject var observersViewModel: ObserversViewModel
  let userId: Int?
  let userName: String?

  var body: some View {
    Button(action: {
      if observersViewModel.isObserverInRecords(userID: userId ?? 0) {
        observersViewModel.removeRecord(userID: userId ?? 0)
      } else {
        observersViewModel.appendRecord(
          name: userName ?? "unknown",
          userID: userId ?? 0)
      }
    }) {
      Image(systemSymbol: observersViewModel.isObserverInRecords(userID: userId ?? 0) ? SFObserverFill : SFObserver)
        .uniformSize()
    }
    .accessibilityLabel(observersViewModel.isObserverInRecords(userID: userId ?? 0) ? favoriteObserverOn : favoriteObserverOff)
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

      Image(systemSymbol: bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) ? SFSpeciesFill : SFSpecies)
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
    BookmarkButtonView(speciesID: 100)
      .environmentObject(mockBookMarksViewModel)
  }
}
