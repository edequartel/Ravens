//
//  ObsRadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/02/2024.
//

import SwiftUI
import SwiftyBeaver
import Alamofire
import AlamofireImage
import AVFoundation
import Kingfisher

struct ObsRadiusView: View {
    let log = SwiftyBeaver.self
    
    @StateObject var obsViewModel = ObsViewModel()
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    @State private var userId: Int = 0
    
    @Binding var selectedObservation: Observation?
    @State var obs: Observation

    private let appIcon = Image("AppIconShare")
    
    var body: some View {
            VStack {
                HStack {
                    VStack {
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(rarityColor(value: obs.rarity))
                            if obs.has_sound ?? false { //for test
                                Image(systemName: "waveform")
                            }
                            if obs.has_photo ?? false {
                                Image(systemName: "photo") //for test
                            }
                            Text("\(obs.species_detail.name)")// \(obs.species_detail.id)")
                                .bold()
                                .lineLimit(1) // Set the maximum number of lines to 1
                                .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                            Spacer()
                            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
                                Image(systemName: "star.fill")
                            }
                        }
                        
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
                }
            
                
                HStack {
                    Text("\(obs.date) \(obs.time ?? "")")
                    Text("\(obs.number) x")
                    Spacer()
                }
                
                    HStack {
                        Text("\(obs.location_detail?.name ?? "name")")
                            .lineLimit(1) // Set the maximum number of lines to 1
                        Spacer()
                        if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
                            Image(systemName: "pentagon.fill")
                        }

                }
                
                if obs.notes?.count ?? 0 > 0 {
                    HStack {
                        Text("\(obs.notes ?? "unknown")")
                            .italic()
                        Spacer()
                    }
                }
                
//                if !settings.hidePictures {
//                    ForEach(obs.photos ?? [], id: \.self) { imageURLString in
//                      KFImage(url: URL(string: imageURLString)) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                      } placeholder: {
//                        ProgressView()
//                      }
//                    }
//                }
                
//                PhotoGridView(photos: obs.photos)
                
//                if (obs.sounds?.count ?? 0)>0 {
//                    HStack {
                        PlayerControlsView(sounds: obs.sounds ?? [] )
//                        Spacer()
//                    }
//                }                
//                if (obs.sounds?.count ?? 0)>0 {
//                    HStack {
//                        PlayerControlsView(audio: ["https://waarneming.nl/media/sound/235291.mp3",
//                                                   "https://waarneming.nl/media/sound/235292.mp3",
//                                                   "https://waarneming.nl/media/sound/235293.mp3"] )
//                        Spacer()
//                    }
//                }
            }
        
            .accessibilityElement(children: .combine)
            .accessibilityLabel("""
                                Species \(obs.species_detail.name) seen,
                                 \(obs.location_detail?.name ?? ""),
                                 date \(obs.date) at time \(obs.time ?? ""),
                                 \(obs.number) times.
                                """
            )
            .accessibilityHint("this is a hint")
        
        
            .padding(4)
        
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                
                let url = URL(string: obs.permalink)!
                ShareLink(
                    item: url
                )
                {
                    Image(systemName: SFShareLink)
                }
                .tint(.obsShareLink)
                
                Button(action: {
                    selectedObservation = obs
                }) {
                    Image(systemName: SFInformation)
                }
                .tint(.obsInformation)
                
                Button(action: {
                    if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
                        log.info("remove areas \(obs.location_detail?.id ?? 0)")
                        areasViewModel.removeRecord(
                            areaID: obs.location_detail?.id ?? 0)
                    } else {
                        log.error("adding area \(obs.location_detail?.id ?? 0)")
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
                        log.info("bookmarks remove")
                        bookMarksViewModel.removeRecord(speciesID:  obs.species_detail.id)
                    } else {
                        bookMarksViewModel.appendRecord(speciesID:  obs.species_detail.id)
                        log.info("bookmarks append")
                    }
                    
                } ) {
                    Image(systemName: SFSpecies)
                }
                .tint(.obsBookmark)
                
                Button(action: {
                    if let url = URL(string: obs.permalink) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: SFObservation)
                }
                .tint(.obsObservation)
                
            }
        .onAppear() {
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




//struct ObsRadiusView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        let exampleObservation = Observation()
//        ObsRadiusView(obs: exampleObservation, selectedObservation: exampleObservation, from: exampleObservation)
//    }
//}
