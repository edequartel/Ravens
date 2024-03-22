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

class FetchRequestManager: ObservableObject {
    private var currentDelay: Double = 0
    private var resetDelayTimer: Timer?
    private let delayIncrement: Double = 0.1 // Time in seconds to wait before each request
    private let resetDelayTime: TimeInterval = 2.0 // Time in seconds to wait before resetting delay
    
    func fetchDataAfterDelay(for obsID: Int, by viewModel: ObsViewModel) {
        // Invalidate existing timer since we're making a new request
        resetDelayTimer?.invalidate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay) {
            viewModel.fetchData(for: obsID)
        }
        currentDelay += delayIncrement // Increase delay for next request
        
        // Reset currentDelay after a specified period without new requests
        resetDelayTimer = Timer.scheduledTimer(withTimeInterval: resetDelayTime, repeats: false) { [weak self] _ in
            self?.currentDelay = 0
        }
    }
}


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
                        Text("\(obsID)")
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
                    
                    if obs.sounds.count>0 {
                        PlayerControlsView(audio: obs.sounds)
                    }
                    
                }
                .font(.customMedium)
            }
            else {
                ProgressView()
            }
        }
        .onAppear {
            fetchRequestManager.fetchDataAfterDelay(for: obsID, by: obsViewModel)
        }
    }
    
}


#Preview {
    ObsView(obsID: 2, showUsername: true)
        .environmentObject(KeychainViewModel())
        .environmentObject(Settings())
}

