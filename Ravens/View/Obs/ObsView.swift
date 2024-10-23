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
  var showSpecies = true
  var showObserver = true
  var showArea = true

  @EnvironmentObject var observersViewModel: ObserversViewModel
  @EnvironmentObject var areasViewModel: AreasViewModel
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  @State var selectedObservation: Observation?
  @State var imageURLStr: String?
  @State var obs: Observation
  
  private let appIcon = Image("AppIconShare")

  var body: some View {
    HStack {
      PhotoThumbnailView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)

      VStack(alignment: .leading) {
        if showView { Text("ObsView").font(.customTiny) }

        HStack {
          if showSpecies {
            ObsDetailsRowView(obs: obs)
          }

          if obs.sounds?.count ?? 0 > 0 {
            Image(systemName: "waveform")
          }


          if obs.notes?.count ?? 0 > 0 {
            Image(systemName: "list.clipboard")
          }
          Spacer()
        }

        if showSpecies {
          Text("\(obs.species_detail.scientific_name)")
            .footnoteGrayStyle()
            .italic()
        }

      HStack {
          DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
//        Text("\(String(describing: obs.timeDate))")
          Text("\(obs.number) x")
            .footnoteGrayStyle()
       }


        // User Info Section
        if showObserver {
          HStack {
            Text("\(obs.user_detail?.name ?? "noName")")
              .footnoteGrayStyle()
            Spacer()
            if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
              Image(systemName: SFObserverFill)
                .foregroundColor(.black)
            }
          }
        }

        if showArea {
          HStack {
            Text("\(obs.location_detail?.name ?? "name")")
              .footnoteGrayStyle()// \(obs.location_detail?.id ?? 0)")
              .lineLimit(1) // Set the maximum number of lines to 1
            Spacer()
            if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
              Image(systemName: SFAreaFill)
            }
          }
        }

        Spacer()
      }
      .padding(2)
    }

    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityObsDetail(obs: obs))
    .accessibilityHint("Tap voor meer details over Informatie over de waarneming.")


    //trailing
    .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
      AreaButtonView(obs: obs)
      BookmarkButtonView(obs: obs)
      ObserversButtonView(obs: obs)
    }

    //leading
    .swipeActions(edge: .leading, allowsFullSwipe: false) {
      ShareLinkButtonView(obs: obs)
      InformationSpeciesButtonView(selectedSpeciesID: $selectedSpeciesID, obs: obs)
      LinkButtonView(obs: obs)
    }
  }

  func accessibilityObsDetail(obs: Observation) -> String {
      let formattedDate = formatDateWithDayOfWeek(Date(), "12:34")
      let speciesName = obs.species_detail.name
      let locationName = obs.location_detail?.name ?? ""
      let number = obs.number
      let userName = obs.user_detail?.name ?? ""

      let formattedString = "\(speciesName), \(locationName), \(formattedDate), \(number) keer. door \(userName)"

      return formattedString
  }
}


//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}

