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
    
    @Binding var selectedObservation: Observation?
    
    @State var obs: Observation
    
    var body: some View {
        LazyVStack {
            VStack {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(RarityColor(value: obs.rarity))
                    
                    if obs.photos?.count ?? 0 > 0 {
                        Image(systemName: "photo")
                    }
                    
                    if obs.sounds?.count ?? 0 > 0 {
                        Image(systemName: "waveform")
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
                
                
                if !settings.hidePictures {
                    PhotoGridView(photos: obs.photos ?? [])
                }
                
            }
            
//            .onTapGesture {
//                showMedia.toggle()
//            }
            
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                
//                Button(action: {
////                    print(obs.photos?.count ?? 0)
//                    photos = obs.photos ?? []
//                    showMedia.toggle()
//                }) {
//                    Text("media")
//                }
                
                let url = URL(string: obs.permalink)!
                ShareLink(
                    item: url
                )
                {
                    Image(systemName: SFShareLink)
                }
                .tint(.obsShareLink)
                

                Button(action: {
                  print("yyy")
                    selectedObservation = obs
                }) {
                    Image(systemName: SFInformation)
                }
                .tint(.obsInformation)
                
                
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
                .accessibility(label: Text("Add observer"))
                
                Button(action: {
                    if let url = URL(string: obs.permalink) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: SFObservation)
                }
                .tint(.obsObservation)
                .accessibility(label: Text("Open observation"))
                
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
                .accessibility(label: Text("Add species to bookmarks"))
                
            }
        }

        .accessibilityElement(children: .combine)
        .accessibilityLabel("""
                             \(obs.species_detail.name) gezien,
                             \(obs.location_detail?.name ?? ""),
                             op \(obs.date), \(obs.time ?? ""),
                             \(obs.number) keer.
                            """
        )
        .accessibilityHint("this is a hint")
        
        
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

