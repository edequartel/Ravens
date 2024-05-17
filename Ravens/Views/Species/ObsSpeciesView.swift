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
    
    @StateObject var obsViewModel = ObsViewModel(settings: Settings())
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var observersViewModel: ObserversViewModel
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    @State private var userId: Int = 0
    
    @State private var explorers: [Int] = []
    
    @State var obs: Observation
    
    var showUsername: Bool = true
    var showLocation: Bool = true
    
    var body: some View {
        LazyVStack {
            VStack {
                if obs.has_photo ?? false {
                    Image(systemName: "photo") //for test
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
                    }
                }
                
                if showUsername && settings.showUser {
                    VStack {
                        HStack {
                            Text("\(obs.user_detail?.name ?? "noName")")
                                .footnoteGrayStyle()
                            Spacer()
                            Text("\(obs.user_detail?.id ?? 0)")
                                .footnoteGrayStyle()
                            
                            if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
                                Image(systemName: "person.fill")
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
                //            .onTapGesture(count: 1) {
                //                if let url = URL(string: obs.permalink) {
                //                    UIApplication.shared.open(url)
                //                }
                //            }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: {
                    if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
                        observersViewModel.removeRecord(userID: obs.user_detail?.id ?? 0)
                    } else {
                        observersViewModel.appendRecord(
                            name: obs.user_detail?.name ?? "unknown",
                            userID: obs.user_detail?.id ?? 0)
                    }
                }) {
                    Image(systemName: "person.fill.badge.plus")
                }
                .tint(.red)
                
                Button(action: {
                    if let url = URL(string: obs.permalink) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "binoculars")
                }
                .tint(.yellow)
                
                
//                if obs.has_photo ?? false {
//                    Image(systemName: "photo") //for test
//                }
                
                //                Button(action: {
                //                    self.selectedInfoItem = species
                //                }) {
                //                    Image(systemName: "info.circle")
                //                }
                //                .tint(.blue)
                //
                //
                //                Button(action: {
                //                    bookMarksViewModel.appendRecord(speciesID: species.id)
                //                } ) {
                //                    Image(systemName: "star.fill")
                //                }
                //                .tint(.green)
                
            }
        }
        .onAppear() {
            if ((obs.has_photo ?? false) || (obs.has_sound ?? false)) {
                obsViewModel.fetchData(for: obs.id ?? 0, completion: {
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

