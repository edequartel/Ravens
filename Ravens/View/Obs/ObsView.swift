//
//  ObsUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/05/2024.
//
// 84878 dwarshuis

import SwiftUI
import SwiftyBeaver
import Alamofire
import AVFoundation

struct ObsView: View {
  let index: Int?
  let log = SwiftyBeaver.self

  @EnvironmentObject var observersViewModel: ObserversViewModel
  @EnvironmentObject var areasViewModel: AreasViewModel
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel

  @EnvironmentObject var favoriteObservationsViewModel: FavoriteObservationsViewModel

  @Binding var selectedSpeciesID: Int?

  var entity: EntityType

  @State var selectedObservation: Observation?
  @State var imageURLStr: String?
  @State var obs: Observation
  
  private let appIcon = Image("AppIconShare")

  var body: some View {
    HStack {
      if entity != .radius {
        PhotoThumbnailView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
      }

      VStack(alignment: .leading) {
        if showView { Text("ObsView").font(.customTiny) }

        HStack {
          //        if let index = index { //edq
          //            Text("\(index+1)")
          //          }

          if entity != .species {
            ObsDetailsRowView(obs: obs)
          }

          if obs.sounds?.count ?? 0 > 0 {
            Image(systemSymbol: .waveform)
              .foregroundColor(Color.gray.opacity(0.8))
          }

          if obs.notes?.count ?? 0 > 0 {
            Image(systemSymbol: .listClipboard)
              .foregroundColor(Color.gray.opacity(0.8))
          }
        }

        if (entity != .species) && (!obs.speciesDetail.name.isEmpty) {
          Text(obs.speciesDetail.scientificName)
            .footnoteGrayStyle()
            .italic()
        }

        HStack {
          DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
          Text("\(obs.number) x")
            .footnoteGrayStyle()
        }

        // User Info Section
        if  (demo) && (entity != .user) && (entity != .radius) {
          RandomTextView()
        }

        if  (!demo) && (entity != .user) && (entity != .radius) {
          HStack {
            Text("\(obs.userDetail?.name ?? "noName")")
              .footnoteGrayStyle()
            Spacer()
            if observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) {
              Image(systemSymbol: SFObserverFill)
                .foregroundColor(Color.gray.opacity(0.8))
            }
          }
        }

        if entity != .location {
          HStack {
            Text("\(obs.locationDetail?.name ?? "name")")
              .footnoteGrayStyle()// \(obs.location_detail?.id ?? 0)")
              .lineLimit(1) // Set the maximum number of lines to 1
            Spacer()
            if areasViewModel.isIDInRecords(areaID: obs.locationDetail?.id ?? 0) {
              Image(systemSymbol: SFAreaFill)
                .foregroundColor(Color.gray.opacity(0.8))
            }
          }
        }
        Spacer()
      }
      .padding(2)
    }

    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityObsDetail(obs: obs))
    .accessibilityHint("Tap for more details about the observation information.")

    // trailing
    .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
      if !keyChainViewModel.token.isEmpty {

        if entity != .location {
          AreaButtonView(obs: obs)
            .tint(.yellow)
        }

        BookmarkButtonView(speciesID: obs.speciesDetail.id)
          .tint(.green)

        if (entity != .radius) && (obs.userDetail?.id != (userViewModel.user?.id ?? 0)) {
          ObserversObsButtonView(obs: obs)
            .tint(.red)
        }
      }

      if entity != .species && [1, 2, 3, 14].contains(obs.speciesDetail.group) {
        NavigationLink(destination: BirdListView(scientificName: obs.speciesDetail.scientificName, nativeName: obs.speciesDetail.name)) {
          Image(systemSymbol: .waveform)
            .uniformSize()
        }
        .tint(.purple)
        .accessibility(label: Text(audioListView))
      }
    }

    .swipeActions(edge: .leading, allowsFullSwipe: false) {
//      ShareLinkButtonView(obs: obs)

//      InformationSpeciesButtonView(selectedSpeciesID: $selectedSpeciesID, obs: obs)

//      LinkButtonView(obs: obs)

      //??! hier een link naar de list met de observations van deze species met boompje

//      Button {
//        favoriteObservationsViewModel.appendRecord(observation: obs)
//      } label: {
//        Image(systemSymbol: .treeFill)
//      }
//      .tint(.blue)

      Button {
        favoriteObservationsViewModel.appendRecord(observation: obs)
      } label: {
        Image(systemSymbol: .bookmarkFill)
      }
      .tint(.green)
    }
  }

  func accessibilityObsDetail(obs: Observation) -> String {
    let formattedDate = convertStringToFormattedDate(dateString: obs.date, timeString: obs.time ?? "") ?? ""
    let speciesName = obs.speciesDetail.name
    let locationName = obs.locationDetail?.name ?? ""
    let number = obs.number
    let userName = obs.userDetail?.name ?? ""

    let formattedString = "\(speciesName), \(locationName), \(String(describing: formattedDate)), \(number) keer. door \(userName)"

    return formattedString
  }
  
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Customize the style: .short, .medium, .long, etc.
    formatter.timeStyle = .short // Customize the style: .none, .short, .medium, .long
    return formatter.string(from: date)
}

let names = [
  "Mees Zilverveer",     // vogel + sierlijke natuurachternaam
  "Eline Waterman",      // water
  "Sil Hazelaar",        // boom (hazelaar)
  "Linde Storm",         // boom + weerfenomeen
  "Roan Veldhuis",       // open natuur + woning
  "Fenna Sterrenberg",   // sterren + berg
  "Thijs Rietveld",      // riet en open land
  "Bente Moeras",        // naam + natuurgebied
  "Noor IJsselstein",    // rivier + plaatsnaamachtig
  "Sterre Zandberg",     // sterren + duin/berg
  "Mats Wolkenveld",     // luchtig en ruimtelijk
  "Jule Dennenbosch"    // bosnaam
]

struct RandomTextView: View {
  @State private var randomName = ""
  var body: some View {
    Text(randomName)
      .font(.caption)
      .onAppear {
        randomName = names.randomElement() ?? "Geen naam"
      }
  }
}
