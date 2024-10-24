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
    
    @StateObject var obsViewModel = ObsViewModel(settings: Settings())
    @EnvironmentObject var settings: Settings
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    @State private var userId: Int = 0
    
    @State private var explorers: [Int] = []
    
    @State var obs: Observation
    
    var showUsername: Bool = true
    var showLocation: Bool = true
    
    var body: some View {
        LazyVStack {
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
                        Text("\(obs.species_detail.name)")
                            .bold()
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        Spacer()
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
            .onTapGesture(count: 1) {
                if let url = URL(string: obs.permalink) {
                    UIApplication.shared.open(url)
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
                }
            }
            
            if showUsername && settings.showUser {
                VStack {
                    HStack {
                        Text("\(obs.user_detail?.name ?? "noName")")
                            .footnoteGrayStyle()
                        Spacer()
                        //                        Text("\(obs.user_detail?.id ?? 0)")
                        //                            .footnoteGrayStyle()
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
//        .accessibility(hidden: true)
        .accessibility(label: Text("Your Label"))
        
        .onAppear() {
            //            settings.readExplorers(array: &explorers)
            
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

