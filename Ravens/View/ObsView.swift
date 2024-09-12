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
  
  @State var selectedObservation: Observation?

  @State var imageURLStr: String?
  @State var obs: Observation
  
  private let appIcon = Image("AppIconShare")

  var body: some View {
    HStack {
      PhotoView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)

      VStack {
        if showView { Text("ObsView").font(.customTiny) }

        if showSpecies {

        ObsDetailsRowView(obs: obs, bookMarksViewModel: bookMarksViewModel)


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
        HStack {
          DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
          Text("\(obs.number) x")
          Spacer()
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
            Text("\(obs.location_detail?.name ?? "name")")// \(obs.location_detail?.id ?? 0)")
              .lineLimit(1) // Set the maximum number of lines to 1
            Spacer()
            if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
              Image(systemName: "pentagon.fill")
            }
          }
        }

        Spacer()

        
      }


      
      
    }
//    .onTapGesture {
//      selectedObs = obs
//    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("""
                                 \(obs.species_detail.name) gezien,
                                 \(obs.location_detail?.name ?? ""),
                                 op \(obs.date), \(obs.time ?? ""),
                                 \(obs.number) keer.
                                """
    )
    
    
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
      
      Button(action: {
        print("xxx \(obs.species_detail.name) \(obs.species_detail.id)")
        selectedObservation = obs
      }) {
        Image(systemName: SFInformation)
      }
      .tint(.obsInformation)
      
      
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
        Image(systemName: SFArea)
      }
      .tint(.obsArea)
      
      Button(action: {
        if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
          print("bookmarks remove")
          bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
        } else {
          bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
          print("bookmarks append")
        }
      } ) {
        Image(systemName: SFSpecies)
      }
      .tint(.obsSpecies)
      
      
      Button(action: {
        if let url = URL(string: obs.permalink) {
          UIApplication.shared.open(url)
        }
        
      }) {
        Image(systemName: SFObservation)
      }
      .tint(.obsObservation)
      
    }
  }
}


//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}

