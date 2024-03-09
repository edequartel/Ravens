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

struct ObsView: View {
    let log = SwiftyBeaver.self
    @StateObject var obsViewModel = ObsViewModel(settings: Settings())
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var keychainViewModel: KeychainViewModel
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    
    var obsID: Int
    var showUsername: Bool
    
    var body: some View {
        LazyVStack {
            if let obs = obsViewModel.observation {
                LazyVStack(alignment: .leading) {
                    Text("Observation ID: \(obs.id)")
                    HStack {
//                        Text("ObsView")
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(myColor(value: obs.rarity ?? 0)))
                        
                        Text("\(obs.species_detail.name)")
                            .bold()
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                        
                        Spacer()
//                        
                        Text("\(obs.species_detail.scientific_name)")
                            .italic()
                            .lineLimit(1) // Set the maximum number of lines to 1
                            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                    }
//                    .onTapGesture {xxx
//                        if let url = URL(string: obs.permalink) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
                    
                    Text("\(obs.date) \(obs.time ?? ""), \(obs.number)")

                    if showUsername {
                        Text("\(obs.user_detail?.name ?? "unknown") - \(obs.user_detail?.id ?? 0)")
                    }
                    
                    Text("\(obs.location_detail?.name ?? "unknown")")
                   
                    if obs.notes?.count ?? 0 > 0 {
                        Text("\(obs.notes ?? "unknown")")
                            .italic()
                    }
                    
                    ForEach(obs.photos, id: \.self) { imageURLString in
                        AFImageView(media: imageURLString)
                    }
                    
                    ForEach(obs.sounds, id: \.self) { audioURL in
//                        Text("Sounds: \(audioURL)")
                        StreamingQueuPlayerView(sounds: obs.sounds)
                    }
                }
                .font(.customMedium)
            }
            else {
                ProgressView("Fetching Observation...")
            }
        }
        .onAppear {
            obsViewModel.fetchData(for: obsID)
        }
    }
}

#Preview {
    ObsView(obsID: 2, showUsername: true)
        .environmentObject(KeychainViewModel())
        .environmentObject(Settings())
}

