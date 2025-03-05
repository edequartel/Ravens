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
//import AlamofireImage
import AVFoundation


struct ObsView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var observersViewModel: ObserversViewModel
  @EnvironmentObject var areasViewModel: AreasViewModel
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var userViewModel:  UserViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel

  @Binding var selectedSpeciesID: Int?

  var entity: EntityType

  @State var selectedObservation: Observation?
  @State var imageURLStr: String?
  @State var obs: Observation
  
  private let appIcon = Image("AppIconShare")

  var body: some View {
    HStack {
      if (entity != .radius) {
        PhotoThumbnailView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
      }

      VStack(alignment: .leading) {
        if showView { Text("ObsView").font(.customTiny) }

        HStack {
          if entity != .species {
            ObsDetailsRowView(obs: obs)
          }

          if obs.sounds?.count ?? 0 > 0 {
            Image(systemName: "waveform")
              .foregroundColor(Color.gray.opacity(0.8))
          }

          if obs.notes?.count ?? 0 > 0 {
            Image(systemName: "list.clipboard")
              .foregroundColor(Color.gray.opacity(0.8))
          }
        }

        if (entity != .species) && (obs.speciesDetail.name.isEmpty) { //?!
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
        if (entity != .user) && (entity != .radius) {
          HStack {
//            RandomTextView()
            Text("\(obs.userDetail?.name ?? "noName")")
              .footnoteGrayStyle()
            Spacer()
            if observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) {
              Image(systemSymbol: SFObserverFill)
                .foregroundColor(Color.gray.opacity(0.8))
            }
          }
        }

        //
        //(obs.userDetail?.id != (userViewModel.user?.id ?? 0)
//        Text("\(obs.userDetail?.id ?? -1)")
//        Text("\(userViewModel.user?.id ?? -1)")
        //

        if (entity != .location) {
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

    //trailing
    .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
      if !keyChainViewModel.token.isEmpty { //??
        AreaButtonView(obs: obs, colorOn: true)

        if (entity != .species) {
          BookmarkButtonView(speciesID: obs.species ?? 0)
        }

        if (entity != .radius) && (obs.userDetail?.id != (userViewModel.user?.id ?? 0)) {
          ObserversButtonView(obs: obs, colorOn: true)
        }

      }
    }

    //leading SWIPE ACTIONS
    .swipeActions(edge: .leading, allowsFullSwipe: false) {
      ShareLinkButtonView(obs: obs)
      if (entity != .species) {
        InformationSpeciesButtonView(selectedSpeciesID: $selectedSpeciesID, obs: obs)
      }
      LinkButtonView(obs: obs)
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


import SwiftUI

struct RandomTextView: View {
    let names = ["Loof de Bos", "Storm Vogelaar", "Flora Fauna", "Henk de Uitzicht", "Bart Kikker",
                 "Madelief Kijkers", "Oogje Bladgroen", "Frits de Horizon",
                 "Tina Terras", "Woody Kijkboom", "Lente Zicht", "Freek de Lucht", "Marjolein Weideblik"]

    @State private var randomName = ""

    var body: some View {
        Text(randomName)
            .font(.caption)
//            .padding()
            .onAppear {
                randomName = names.randomElement() ?? "Geen naam"
            }
    }
}
