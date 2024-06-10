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
import AlamofireImage
import AVFoundation

struct ObsUserView: View {
    let log = SwiftyBeaver.self
    
//    @StateObject var obsViewModel = ObsViewModel()
    
//    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    
//    @State private var selectedImageURL: URL?
//    @State private var isShareSheetPresented = false
    @State private var showingDetails = false
    
    @State var obs: Observation

    var body: some View {
//        LazyVStack {
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
                
                HStack {
                    Text("\(obs.date) \(obs.time ?? "")")
                    Text("\(obs.number) x")
                    Spacer()
                }
                
                
                HStack {
                    Text("\(obs.location_detail?.name ?? "name")")// \(obs.location_detail?.id ?? 0)")
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
                        bookMarksViewModel.removeRecord(speciesID: obs.species_detail.id)
                    } else {
                        bookMarksViewModel.appendRecord(speciesID: obs.species_detail.id)
                        print("bookmarks append")
                    }
                } ) {
                    Image(systemName: "star.fill")
                }
                .tint(.obsStar)
                
                
                Button(action: {
                    if let url = URL(string: obs.permalink) {
                        UIApplication.shared.open(url)
                    }
                    
                }) {
                    Image(systemName: "binoculars")
                }
                .tint(.yellow)
                
                Button(action: {
                    print("Button tapped + Show Image from URL \(obs.species_detail.id)")
                    showingDetails = true
                }) {
                    Image(systemName: "info.circle")
                }
                .tint(.blue)
            }
//        }
//        .sheet(isPresented: $showingDetails) {
//            SpeciesDetailsView(speciesID: obs.species_detail.id)
//        }
    }
}

//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize your ObsView with appropriate data
//        ObsView(obs: Observation(from: <#any Decoder#>))
//    }
//}

