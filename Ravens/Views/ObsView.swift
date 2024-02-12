//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/02/2024.
//

import SwiftUI
import SwiftyBeaver
import Kingfisher

struct ObsView: View {
    let log = SwiftyBeaver.self
    @ObservedObject var viewModel = ObsViewModel()
    @EnvironmentObject var settings: Settings
    
    var obsID: Int

    var body: some View {
        VStack {
            if let observation = viewModel.observation {
                VStack(alignment: .leading) {
                    Text("SpeciesDetailsName: \(observation.species_detail.name)")
                    Text("Observation ID: \(observation.id)")
                    Text("Species: \(observation.species)")
                }
                
//                ForEach(observation.photos, id: \.self) { imageURLString in
//                    Text("\(imageURLString)")
//                    if URL(string: imageURLString) != nil {
//                        KFImage(URL(string: imageURLString)!)
//                            .resizable()
//                            .aspectRatio(nil, contentMode: .fit)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    } else {
//                        Text("Invalid URL")
//                    }
//                }
                
//                ForEach(observation.sounds, id: \.self) { audioURL in
//                    Text("\(audioURL)")
//                }

            } 
            else {
                ProgressView("Fetching Observation...")
            }
        }
        .onAppear {
            viewModel.fetchData(for: obsID, language: settings.selectedLanguage, token: tokenKey)
        }
    }
}

#Preview {
    ObsView(obsID: 123629598)
}
