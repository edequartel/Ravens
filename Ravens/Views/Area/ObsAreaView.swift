//
//  ObsAreaView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/05/2024.
//


import SwiftUI
import SwiftyBeaver
import Alamofire
import AlamofireImage
import AVFoundation

struct ObsAreaView: View {
    let log = SwiftyBeaver.self
    
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
    
//    @Binding var selectedObservation: Observation?
    
    private let appIcon = Image("AppIconShare")
    
    @State var obs: Observation
    
    var body: some View {
        LazyVStack {
            VStack {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(myColor(value: obs.rarity)))
                    
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
                        Image(systemName: SFSpeciesFill)
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
                
                HStack {
                    Text("\(obs.date) \(obs.time ?? "")")
                    Text("\(obs.number) x")
                    Spacer()
                }
                
                if settings.showUser {
                    VStack {
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
                }
                
                if obs.notes?.count ?? 0 > 0 {
                    HStack {
                        Text("\(obs.notes ?? "unknown")")
                            .italic()
                        Spacer()
                    }
                }
                
                ForEach(obs.photos ?? [], id: \.self) { imageURLString in
                    AFImageView(media: imageURLString)
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
                
                
                Button(action: {
                    if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
                        observersViewModel.removeRecord(
                            userID: obs.user_detail?.id ?? 0)
                    } else {
                        
                        observersViewModel.appendRecord(
                            name: obs.user_detail?.name ?? "unknown",
                            userID: obs.user_detail?.id ?? 0)
                    }
                    
                    
                }) {
                    Image(systemName: observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) ? SFObserverMin : SFObserverPlus)
                }
                .tint(.obsObserver)
                
                Button(action: {
                    if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
                        log.info("remove areas \(obs.location_detail?.id ?? 0)")
                        areasViewModel.removeRecord(
                            areaID: obs.location_detail?.id ?? 0)
                    } else {
                        log.info("adding area \(obs.location_detail?.id ?? 0)")
                        areasViewModel.appendRecord(
                            areaName: obs.location_detail?.name ?? "unknown",
                            areaID: obs.location_detail?.id ?? 0,
                            latitude: obs.point.coordinates[1], //!!?
                            longitude: obs.point.coordinates[0])
                    }
                }) {
                    Image(systemName: SFArea)
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
                
                Button(action: {
                    if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
                        log.info("bookmarks remove")
                        bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
                    } else {
                        bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
                        log.info("bookmarks append")
                    }

                } ) {
                    Image(systemName: SFSpecies)
                }
                .tint(.obsSpecies)
                
            }
        }
        .padding(4)
        
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

//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}

