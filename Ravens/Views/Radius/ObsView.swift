//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/02/2024.
//

import SwiftUI
import SwiftyBeaver
import Alamofire
import AlamofireImage
import AVFoundation

struct ObsView: View {
    let log = SwiftyBeaver.self
    
    @StateObject var obsViewModel = ObsViewModel()
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    @State private var userId: Int = 0
    @State private var showingDetails = false
    
    @State private var explorers: [Int] = []
    
    @State var obs: Observation
    
    var showUsername: Bool = true
    var showLocation: Bool = true
    
    var body: some View {
        LazyVStack {
            VStack {
                HStack {
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
                                //                                        if isNumberInBookMarks(number: species.id) {
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
//                            Text("info obs: \(obs.id ?? 0)")
//                                .footnoteGrayStyle()
                        }
                    }
                }
                
                
                
                HStack {
                    Text("\(obs.date) \(obs.time ?? "")")
                    Text("\(obs.number) x")
                    Spacer()
                }
                
                if showLocation {
                    HStack {
                        Text("\(obs.location_detail?.name ?? "name")")
                            .lineLimit(1) // Set the maximum number of lines to 1
                        Spacer()
                        if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
                            Image(systemName: "pentagon.fill")
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
            .onTapGesture(count: 1) {
                if let url = URL(string: obs.permalink) {
                    UIApplication.shared.open(url)
                }
            }
            
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                
                Button(action: {
                    print("Button tapped + Show Image from URL \(obs.species_detail.id)")
                    showingDetails = true
                }) {
                    Image(systemName: "info.circle")
                }
                .tint(.blue)

                //
                Button(action: {
                    if areasViewModel.isIDInRecords(areaID: obs.location_detail?.id ?? 0) {
                        print("remove areas \(obs.location_detail?.id ?? 0)")
                        areasViewModel.removeRecord(
                            areaID: obs.location_detail?.id ?? 0)
                    } else {
                        print("adding area \(obs.location_detail?.id ?? 0)")
                        areasViewModel.appendRecord(
                            areaName: obs.location_detail?.name ?? "unknown",
                            areaID: obs.location_detail?.id ?? 0)
                    }
                }) {
                    Image(systemName: observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) ? "pentagon" : "pentagon")
                    
                }
                .tint(.green)
                
                Button(action: {
                    if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
                        print("bookmarks remove")
                        bookMarksViewModel.removeRecord(speciesID:  obs.species_detail.id)
                    } else {
                        bookMarksViewModel.appendRecord(speciesID:  obs.species_detail.id)
                        print("bookmarks append")
                    }

                } ) {
                    Image(systemName: "star")
                }
                .tint(.obsStar)
                
                
                //
                
                Button(action: {
                    if let url = URL(string: obs.permalink) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "binoculars.fill")
                }
                .tint(.yellow)

            }
            
            
        }
        //        .accessibility(hidden: true)
        //        .accessibility(label: Text("Your Label"))
        .sheet(isPresented: $showingDetails) {
            SpeciesDetailsView(speciesID: obs.species_detail.id)
        }
        
        .onAppear() {
            //            settings.readExplorers(array: &explorers)
            
            if ((obs.has_photo ?? false) || (obs.has_sound ?? false)) {
                obsViewModel.fetchData(language: settings.selectedLanguage, for: obs.id ?? 0, completion: {
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

