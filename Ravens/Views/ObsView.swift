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
    
    @StateObject var obsViewModel = ObsViewModel(settings: Settings()) //??
    @EnvironmentObject var fetchRequestManager: FetchRequestManager

    @State private var selectedImageURL: URL?
    @State private var isShareSheetPresented = false
    
    @State var obs: Observation
    var showUsername: Bool = true
    var showLocation: Bool = true
    
    var body: some View {
        LazyVStack {
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
            
            HStack {
                Text("\(obs.date) \(obs.time ?? "") -  \(obs.number)x")
                Spacer()
            }
            
            if showUsername {
                HStack {
                    Text("\(obs.user_detail?.name ?? String(obs.user))")
                    Spacer()
//                    Text("\(obs.user_detail?.id ?? 0)")
                }
            }
            
            if showLocation {
                HStack {
                    Text("\(obs.location_detail?.name ?? "name")")
                        .lineLimit(1) // Set the maximum number of lines to 1
                    Spacer()
//                    Text("\(obs.location_detail?.id ?? 0)")
                        .lineLimit(1) // Set the maximum number of lines to 1
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
        .onAppear() {
            if ((obs.has_photo ?? false) || (obs.has_sound ?? false)) {
                
//                fetchRequestManager.fetchDataAfterDelay(for: obs.id ?? 0, by: obsViewModel, completion: {
//                    print("onAppear OBSView Happens")
//                    obs.photos = obsViewModel.observation?.photos
//                    obs.sounds = obsViewModel.observation?.sounds
//                })                
                
                obsViewModel.fetchData(for: obs.id ?? 0, completion: {
                    print("onAppear OBSView Happens")
                    obs.photos = obsViewModel.observation?.photos
                    obs.sounds = obsViewModel.observation?.sounds
                })

            }
        }
    }
}


//#Preview {
////    var obs: ObservationSpecies
//    ObsView(obs: ObservationSpecies)
//}

//struct ObsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ObsView(obs: ObservationSpecies(
//            id: 1,
//            species_detail: SpeciesDetail(
//                id: 1,)
//    }
//}





