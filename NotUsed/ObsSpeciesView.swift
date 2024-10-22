////
////  ObsSpeciesView.swift
////  Ravens
////
////  Created by Eric de Quartel on 15/05/2024.
////
//
//
//import SwiftUI
//import SwiftyBeaver
//import Alamofire
//import AlamofireImage
//import AVFoundation
//
//struct ObsSpeciesView: View {
//  let log = SwiftyBeaver.self
//
//  @StateObject var obsViewModel = ObsViewModel()
//  @EnvironmentObject var speciesViewModel: SpeciesViewModel
//
//  @EnvironmentObject var settings: Settings
//  @EnvironmentObject var observersViewModel: ObserversViewModel
//  @EnvironmentObject var areasViewModel: AreasViewModel
//  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
//
//  private let appIcon = Image("AppIconShare")
//
//  @State var obs: Observation
//  @State var selectedObs: Observation?
//  @State var imageURLStr: String?
//  @State private var selectedObservation: Observation?
//
//  var showUsername: Bool = true
//  var showLocation: Bool = true
//
//  var body: some View {
////    LazyVStack {
//      HStack {
//        PhotoView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
//        VStack {
//          if showView { Text("ObsSpeciesView").font(.customTiny) }
//
//
//          ObsDetailsRowView(obs: obs, bookMarksViewModel: bookMarksViewModel)
//
//          HStack {
//            DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
//            Text("\(obs.number) x")
//            Spacer()
//          }
//
//          if showUsername && settings.showUser {
//            VStack {
//              HStack {
//                Text("\(obs.user_detail?.name ?? "noName")")
//                  .footnoteGrayStyle()
//                Spacer()
//                if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
//                  Image(systemName: SFObserverFill)
//                }
//              }
//            }
//          }
//
//          Spacer()
//        }
//
//
//
//
//      }
//      .accessibilityElement(children: .combine)
//      .accessibilityLabel("""
//                                 \(obs.has_sound ?? false ? "met geluid" : ""),
//                                 op \(obs.date), \(obs.time ?? "00"),
//                                 \(obs.number) keer.
//                                 \(obs.notes?.count ?? 0 > 0 ? obs.notes ?? "unknown" : "")
//                                """
//      )
//
//      //                                 \(obs.location_detail?.name ?? ""),
//
//      .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//
//        let url = URL(string: obs.permalink)!
//        ShareLink(
//          item: url
//        )
//        {
//          Image(systemName: SFShareLink)
//        }
//        .tint(.obsShareLink)
//
//        Button(action: {
//          if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
//            observersViewModel.removeRecord(userID: obs.user_detail?.id ?? 0)
//          } else {
//            observersViewModel.appendRecord(
//              name: obs.user_detail?.name ?? "unknown",
//              userID: obs.user_detail?.id ?? 0)
//          }
//        }) {
//          Image(systemName: observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) ? SFObserverMin : SFObserverPlus)
//
//        }
//        .tint(.obsObserver)
//
//        Button(action: {
//          if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
//            print("remove areas \(obs.location_detail?.id ?? 0)")
//            areasViewModel.removeRecord(
//              areaID: obs.location_detail?.id ?? 0)
//          } else {
//            print("adding area \(obs.location_detail?.id ?? 0)")
//            areasViewModel.appendRecord(
//              areaName: obs.location_detail?.name ?? "unknown",
//              areaID: obs.location_detail?.id ?? 0,
//              latitude: obs.point.coordinates[1], //!!? reversed
//              longitude: obs.point.coordinates[0])
//          }
//        }) {
//          Image(systemName: SFArea)
//        }
//        .tint(.obsArea)
//
//        Button(action: {
//          if let url = URL(string: obs.permalink) {
//            UIApplication.shared.open(url)
//          }
//        }) {
//          Image(systemName: SFObservation)
//        }
//        .tint(.obsObservation)
//
//
//
////      }
//    }
////    .onTapGesture {
////      selectedObs = obs
////    }
//    .onAppear() { //if the obs has photos or sounds get them
//      if ((obs.has_photo ?? false) || (obs.has_sound ?? false)) {
//        obsViewModel.fetchData(settings: settings, for: obs.id ?? 0, completion: {
//          log.info("onAppear OBSView Happens")
//          obs.photos = obsViewModel.observation?.photos
//          obs.sounds = obsViewModel.observation?.sounds
//        })
//
//      }
//    }
//  }
//}
//
////struct ObsSpeciesView_Previews: PreviewProvider {
////    static var previews: some View {
////        ObsSpeciesView(
////            obs: Observation(
////                id: 1,
////                date: "2021-01-01",
////                time: "12:00",
////                number: 1,
////                has_photo: true,
////                has_sound: true,
////                notes: "notes",
////                location_detail: Location(id: 1, name: "location"),
////                user_detail: User(id: 1, name: "user"),
////                species_detail: Species(id: 1, name: "species"),
////                point: Point(coordinates: [0.0, 0.0]),
////                permalink: "https://www.inaturalist.org/observations/1"
////            )
////        )
////        .environmentObject(Settings())
////        .environmentObject(ObserversViewModel())
////        .environmentObject(AreasViewModel())
////        .environmentObject(BookMarksViewModel())
////    }
////}
