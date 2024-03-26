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
    @EnvironmentObject var keychainViewModel: KeychainViewModel
    
    @EnvironmentObject var fetchRequestManager: FetchRequestManager
    
    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    
    var obsID: Int
    var showUsername: Bool
    
    var body: some View {
        LazyVStack {
            if let obs = obsViewModel.observation {
                LazyVStack(alignment: .leading) {
                    HStack {
//                        Text("\(obsID)")
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
                    .onTapGesture { //sounds
                        if let url = URL(string: obs.permalink) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Text("\(obs.date) \(obs.time ?? ""), \(obs.number)")
                    
                    if showUsername {
                        HStack {
                            Text("\(obs.user_detail?.name ?? "unknown")")
                            Spacer()
                            Text("\(obs.user_detail?.id ?? 0)")
                        }
                    }
                    
                    HStack {
                        Text("\(obs.location_detail?.name ?? "unknown")")
                        Spacer()
                        Text("\(obs.location_detail?.id ?? 0)")
                    }
                    
                    if obs.notes?.count ?? 0 > 0 {
                        Text("\(obs.notes ?? "unknown")")
                            .italic()
                    }
                    
                    ForEach(obs.photos, id: \.self) { imageURLString in
                        AFImageView(media: imageURLString)
                    }
                    
                    if obs.sounds.count>0 {
                        PlayerControlsView(audio: obs.sounds)
                    }
                    
                    
                }
                .font(.customMedium)
            }
            else {
                ProgressView()
            }
//            Divider()
        }
        .onAppear {
            fetchRequestManager.fetchDataAfterDelay(for: obsID, by: obsViewModel)
        }
        
//        .padding(.top, 20)
//        .padding(.horizontal, 20)
    }
    
}


#Preview {
    ObsView(obsID: 2, showUsername: true)
        .environmentObject(KeychainViewModel())
        .environmentObject(Settings())
}

