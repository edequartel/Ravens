//
//  ObsAreaView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/05/2024.
//


import SwiftUI
import SwiftyBeaver
import Alamofire
//import AlamofireImage
import AVFoundation

struct ObsAreaView: View {
    let log = SwiftyBeaver.self
  var showSpecies = true
  var showObserver = true
  var showArea = true


    @StateObject var obsViewModel = ObsViewModel()

    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel

    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    @State private var userId: Int = 0

    @State private var selectedSpecies: Int?
    @State private var showSelectedSpeciesId = false
    @State private var showingDetails = false

    @Binding var selectedObservation: Observation?

    @State var imageURLStr: String?
    @State var obs: Observation

    var body: some View {
        HStack(spacing: 2) {
            // Photo Section
            PhotoView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)

            // Observation Details Section
            VStack(alignment: .leading, spacing: 2) {
                // Title
                if showView {
                    Text("ObsAreaView")
                        .font(.customTiny)
                }

                // Observation Details
                ObsDetailsRowView(obs: obs, bookMarksViewModel: bookMarksViewModel)

                // Scientific Name
                Text("\(obs.species_detail.scientific_name)")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .italic()
                    .lineLimit(1)
                    .truncationMode(.tail)

                // Date and Count
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

                Spacer()
            }
            .padding(.leading)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActionButtons
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelContent())
        .accessibilityHint("this is a hint")
        .onAppear {
            fetchObservationData()
        }
    }

    // Extracted Swipe Action Buttons
    private var swipeActionButtons: some View {
        Group {
            ShareLink(item: URL(string: obs.permalink)!) {
                Image(systemName: SFShareLink)
            }
            .tint(.obsShareLink)

            Button(action: {
                selectedObservation = obs
            }) {
                Image(systemName: SFInformation)
            }
            .tint(.obsInformation)

            observerRecordButton
            openObservationButton
            bookmarkButton
        }
    }

    // Observer Record Button
    private var observerRecordButton: some View {
        Button(action: {
            if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
                observersViewModel.removeRecord(userID: obs.user_detail?.id ?? 0)
            } else {
                observersViewModel.appendRecord(
                    name: obs.user_detail?.name ?? "unknown",
                    userID: obs.user_detail?.id ?? 0)
            }
        }) {
            Image(systemName: observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) ? SFObserverMin : SFObserverPlus)
        }
        .tint(.obsObserver)
        .accessibility(label: Text("Add observer"))
    }

    // Open Observation Button
    private var openObservationButton: some View {
        Button(action: {
            if let url = URL(string: obs.permalink) {
                UIApplication.shared.open(url)
            }
        }) {
            Image(systemName: SFObservation)
        }
        .tint(.obsObservation)
        .accessibility(label: Text("Open observation"))
    }

    // Bookmark Button
    private var bookmarkButton: some View {
        Button(action: {
            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
                log.info("bookmarks remove")
                bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
            } else {
                bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
                log.info("bookmarks append")
            }
        }) {
            Image(systemName: SFSpecies)
        }
        .tint(.obsSpecies)
        .accessibility(label: Text("Add species to bookmarks"))
    }

    // Fetch Observation Data on Appear
    private func fetchObservationData() {
        if (obs.has_photo ?? false) || (obs.has_sound ?? false) {
            obsViewModel.fetchData(settings: settings, for: obs.id ?? 0) {
                log.info("onAppear OBSView Happens")
                obs.photos = obsViewModel.observation?.photos
                obs.sounds = obsViewModel.observation?.sounds
            }
        }
    }

    // Accessibility Label Content
    private func accessibilityLabelContent() -> String {
        """
        \(obs.species_detail.name) seen at \(obs.location_detail?.name ?? ""),
        on \(obs.date), \(obs.time ?? ""),
        observed \(obs.number) times.
        """
    }
}


//struct ObsAreaView: View {
//  let log = SwiftyBeaver.self
//
//  @StateObject var obsViewModel = ObsViewModel()
//
//  @EnvironmentObject var settings: Settings
//  @EnvironmentObject var observersViewModel: ObserversViewModel
//  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
//  @EnvironmentObject var areasViewModel: AreasViewModel
//
//
//  @State private var selectedImageURL: URL?
//  @State private var isShareSheetPresented = false
//  @State private var userId: Int = 0
//
//  @State private var selectedSpecies: Int?
//  @State private var showSelectedSpeciesId = false
//  @State private var showingDetails = false
//
//  @Binding var selectedObservation: Observation?
////  @Binding var selectedObs: Observation?
//
//  @State var imageURLStr: String?
//
//  @State var obs: Observation
//
//  var body: some View {
////    LazyVStack {
//      HStack {
//        
//        PhotoView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
////          .background(Color.gray)
//
//        VStack {
//          if showView { Text("ObsAreaView").font(.customTiny) }
//
//          ObsDetailsRowView(obs: obs, bookMarksViewModel: bookMarksViewModel)
//          HStack {
//            Text("\(obs.species_detail.scientific_name)")
//              .foregroundColor(.gray)
//              .font(.footnote)
//              .italic()
//              .lineLimit(1) // Set the maximum number of lines to 1
//              .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
//            Spacer()
//          }
//
//          HStack {
//            DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
//            Text("\(obs.number) x")
//            Spacer()
//          }
//
//          if settings.showUser {
//            VStack {
//              HStack {
//                Text("\(obs.user_detail?.name ?? "noName")")
//                  .footnoteGrayStyle()
//                Spacer()
//                if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
//                  Image(systemName: SFObserverFill)
//                    .foregroundColor(.black)
//                }
//              }
//            }
//          }
//          Spacer()
//        }
////        if (!settings.hidePictures) {
//
//        }
//
//
////      .onTapGesture {
////        selectedObs = obs
////      }
//
//      .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//
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
//
//        Button(action: {
//          print("yyy")
//          selectedObservation = obs
//        }) {
//          Image(systemName: SFInformation)
//        }
//        .tint(.obsInformation)
//
//
//        Button(action: {
//          if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
//            observersViewModel.removeRecord(
//              userID: obs.user_detail?.id ?? 0)
//          } else {
//
//            observersViewModel.appendRecord(
//              name: obs.user_detail?.name ?? "unknown",
//              userID: obs.user_detail?.id ?? 0)
//          }
//        }) {
//          Image(systemName: observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) ? SFObserverMin : SFObserverPlus)
//        }
//        .tint(.obsObserver)
//        .accessibility(label: Text("Add observer"))
//
//        Button(action: {
//          if let url = URL(string: obs.permalink) {
//            UIApplication.shared.open(url)
//          }
//        }) {
//          Image(systemName: SFObservation)
//        }
//        .tint(.obsObservation)
//        .accessibility(label: Text("Open observation"))
//
//        Button(action: {
//          if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
//            log.info("bookmarks remove")
//            bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
//          } else {
//            bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
//            log.info("bookmarks append")
//          }
//
//        } ) {
//          Image(systemName: SFSpecies)
//        }
//        .tint(.obsSpecies)
//        .accessibility(label: Text("Add species to bookmarks"))
//
////      }
//    }
//
//    .accessibilityElement(children: .combine)
//    .accessibilityLabel("""
//                             \(obs.species_detail.name) gezien,
//                             \(obs.location_detail?.name ?? ""),
//                             op \(obs.date), \(obs.time ?? ""),
//                             \(obs.number) keer.
//                            """
//    )
//    .accessibilityHint("this is a hint")
//
//
//    .onAppear() {
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

//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}

