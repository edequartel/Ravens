//
//  ObsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/05/2024.
//


import SwiftUI
import SwiftyBeaver
import Alamofire
import AlamofireImage
import AVFoundation

struct ObsSpeciesView: View {
    let log = SwiftyBeaver.self
    
    @StateObject var obsViewModel = ObsViewModel()
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    @State private var userId: Int = 0
    
    @State private var explorers: [Int] = []
    
    private let appIcon = Image("AppIconShare")
    
//    @Binding var selectedObservation: Observation?
    @State var obs: Observation
    
    var showUsername: Bool = true
    var showLocation: Bool = true
    
    var body: some View {
        LazyVStack {
            VStack {
                HStack {
                    if obs.photos?.count ?? 0 > 0 {
                        Image(systemName: "photo")
                    }
                    
                    if obs.sounds?.count ?? 0 > 0 {
                        Image(systemName: "waveform")
                    }
                    
//                }
                
//                if showLocation {
                    HStack {
                        Text("\(obs.location_detail?.name ?? "name")")
                            .bold()
                            .lineLimit(1) // Set the maximum number of lines to 1
                        Spacer()
                        if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
                            Image(systemName: SFAreaFill)
//                                .foregroundColor(.green)
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    Text("\(obs.date) \(obs.time ?? "")")
                    Text("\(obs.number) x")
                    Spacer()
                }
                
                if showUsername && settings.showUser {
                    VStack {
                        HStack {
                            Text("\(obs.user_detail?.name ?? "noName")")
                                .footnoteGrayStyle()
//                            Spacer()
//                            Text("\(obs.user_detail?.id ?? 0)")
//                                .footnoteGrayStyle()
                            Spacer()
                            if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
                                Image(systemName: SFObserverFill)
//                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                
                if obs.notes?.count ?? 0 > 0 {
                    HStack {
                        Text("\(obs.notes ?? "unknown")")
                            .italic()
                        Spacer()
                    }
                }
                
                if !settings.hidePictures {
                    ForEach(obs.photos ?? [], id: \.self) { imageURLString in
                        AFImageView(media: imageURLString)
                    }
                }
                
                if (obs.sounds?.count ?? 0)>0 {
                    HStack {
                        PlayerControlsView(audio: obs.sounds ?? [] )
                        Spacer()
                    }
                }
            }
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
                
//                Button(action: {
//                    selectedObservation = obs
//                }) {
//                    Image(systemName: SFInformation)
//                }
//                .tint(.obsInformation)
                
                
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
                
//                Button(action: {
//                    if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
//                        print("bookmarks remove")
//                        bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
//                    } else {
//                        bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
//                        print("bookmarks append")
//                    }
//
//                } ) {
//                    Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) ? SFSpeciesFill : SFSpecies)
//                }
//                .tint(.obsSpecies)

                
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
                            latitude: obs.point.coordinates[1], //!!? reversed
                            longitude: obs.point.coordinates[0])
                    }
                }) {
                    Image(systemName: SFArea)
//                    Image(systemName: areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) ? "pentagon" : "pentagon")
                }
                .tint(.obsArea)
                
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
        .onAppear() { //if the obs has photos or sounds get them
            if ((obs.has_photo ?? false) || (obs.has_sound ?? false)) {
                obsViewModel.fetchData(settings: settings, for: obs.id ?? 0, completion: {
                    log.info("onAppear OBSView Happens")
                    obs.photos = obsViewModel.observation?.photos
                    obs.sounds = obsViewModel.observation?.sounds
                })
                
            }
        }
    }
}

//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}

