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
    
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var areasViewModel: AreasViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    @EnvironmentObject var settings: Settings
    
    
    @Binding var selectedObservation: Observation?
//    @Binding var showPictureSheet: Bool?
    
    @State var obs: Observation
    
    private let appIcon = Image("AppIconShare")
    


    var body: some View {
//        LazyVStack {
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
                
//                if !settings.hidePictures {
//                    ForEach(obs.photos ?? [], id: \.self) { imageURLString in
//                        AFImageView(media: imageURLString)
//                    }
//                }
                
                if !settings.hidePictures {
                    PhotoGridView(photos: obs.photos ?? [])
//                    .frame(height: 200)
                }

                
//                if (obs.sounds?.count ?? 0)>0 {
//                    HStack {
//                        PlayerControlsView(audio: obs.sounds ?? [] )
//                        Spacer()
//                    }
//                }
            }
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

