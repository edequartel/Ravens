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

//      Text("\(obs.date) \(obs.time ?? "00:00")")
//      Text("\(convertStringToFormattedDate(dateString: obs.date, timeString: obs.time ?? "") ?? "")")


      VStack(alignment: .leading) {
        if showView { Text("ObsView").font(.customTiny) }

        HStack {
          if showSpecies {
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
//          Spacer()
        }

//        let defaultDate = Date(timeIntervalSince1970: 0)
//        Text(formatDate(obs.timeDate ?? defaultDate))
//          .font(.caption)

        if showSpecies {
          Text("\(obs.speciesDetail.scientificName)")
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
            Text("\(obs.userDetail?.name ?? "noName")")
              .footnoteGrayStyle()
            Spacer()
            if observersViewModel.isObserverInRecords(userID: obs.userDetail?.id ?? 0) {
              Image(systemSymbol: SFObserverFill)
                .foregroundColor(Color.gray.opacity(0.8))
            }
          }
        }

        if showArea {
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
      AreaButtonView(obs: obs, colorOn: true)
      BookmarkButtonView(obs: obs, colorOn: true)
      ObserversButtonView(obs: obs, colorOn: true)
    }

    //leading SWIPE ACTIONS
    .swipeActions(edge: .leading, allowsFullSwipe: false) {
      ShareLinkButtonView(obs: obs)
      InformationSpeciesButtonView(selectedSpeciesID: $selectedSpeciesID, obs: obs)
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

//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Customize the style: .short, .medium, .long, etc.
    formatter.timeStyle = .short // Customize the style: .none, .short, .medium, .long
    return formatter.string(from: date)
}
