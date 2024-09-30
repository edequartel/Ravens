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

      VStack {
        if showView { Text("ObsView").font(.customTiny) }

//        HStack {
//          Text("---")
//          Spacer()
//        }

        if showSpecies {
          ObsDetailsRowView(obs: obs)
          HStack {
            Text("\(obs.species_detail.scientific_name)")
              .foregroundColor(.gray)
              .font(.footnote)
              .italic()
              .lineLimit(1) // Set the maximum number of lines to 1
              .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
            Spacer()
          }
        }

//        if !showSpecies {
//
//          HStack {
//            if obs.sounds?.count ?? 0 > 0 {
//              Image(systemName: "waveform")
//            }
//            else { Text("") }
//
//            if obs.notes?.count ?? 0 > 0 {
//              Image(systemName: "list.clipboard")
//            }
//            Spacer()
//          }
//        }
//        HStack {
//          Text("---")
//          Spacer()
//        }
        //<<


        HStack {
          DateConversionView(dateString: obs.date, timeString: obs.time ?? "")

          Text("\(obs.number) x")
            .footnoteGrayStyle()
          Spacer()
        }


        // User Info Section
        if showObserver {
          HStack {
            Text("\(obs.user_detail?.name ?? "noName")")
//              .footnoteGrayStyle()
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
    }

    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityObsDetail(obs: obs))
    .accessibilityHint("Tap voor meer details over Informatie over de waarneming.")



    //trailing
    .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
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

      Button(action: {
        if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
          print("bookmarks remove")
          bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
        } else {
          bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
          print("bookmarks append")
        }
      } ) {
        Image(systemName:  SFSpeciesFill)
      }
      .tint(.obsSpecies)
      .accessibility(label: Text("Add bookmark"))

      Button(action: {
        if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
          observersViewModel.removeRecord(userID: obs.user_detail?.id ?? 0)
        } else {
          observersViewModel.appendRecord(
            name: obs.user_detail?.name ?? "unknown",
            userID: obs.user_detail?.id ?? 0)
        }
      }) {
        Image(systemName: SFObserver)
      }
      .tint(.obsObserver)
      .accessibility(label: Text("Add observer"))
    }



    //leading
    .swipeActions(edge: .leading, allowsFullSwipe: false) {
      let url = URL(string: obs.permalink)!
      ShareLink(
        item: url
        //                    message: Text(messageString()),
        //                    preview: SharePreview("Observation"+" \(obs.species_detail.name)", image: appIcon)
      )
      {
        Image(systemName: SFShareLink)
      }
      .tint(.obsShareLink)
      .accessibility(label: Text("Share observation"))

      Button(action: {
        print("Information \(obs.species_detail.name) \(obs.species_detail.id)")
        selectedSpeciesID = obs.species_detail.id
        //    }
      }) {
        Image(systemName: SFInformation)
      }
      .tint(.obsInformation)
      .accessibility(label: Text("Information species"))

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

