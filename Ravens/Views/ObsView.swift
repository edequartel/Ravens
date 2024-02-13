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
    @StateObject var viewModel = ObsViewModel()
    
    @EnvironmentObject var settings: Settings
    
    var obsID: Int
    
    var body: some View {
        LazyVStack {
            if let obs = viewModel.observation {
                LazyVStack(alignment: .leading) {
                    //Text("Observation ID: \(obs.id)")
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(myColor(value: obs.rarity ?? 0)))
                        Text("\(obs.species_detail.name)")
                            .bold()
                    }
                    
                    Text("\(obs.date) \(obs.time ?? "")")
                    Text("\(obs.user_detail?.name ?? "unknown")")
                    Text("\(obs.location_detail?.name ?? "unknown")")
                    
                    ForEach(obs.photos, id: \.self) { imageURLString in
                        if URL(string: imageURLString) != nil {
                            KFImage(URL(string: imageURLString)!)
                                .resizable()
                                .aspectRatio(nil, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                        } else {
                            Text("Invalid URL")
                        }
                    }
                    .onTapGesture {
                        if let url = URL(string: obs.permalink) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    ForEach(obs.sounds, id: \.self) { audioURL in
                        Text("Sounds: \(audioURL)")
                    }
                }
                .font(.footnote)
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
        .environmentObject(Settings())
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


//                    Text("Number: \(obs.number)")
//                    Text("Sex: \(obs.sex)")
//                    Text("Point count: \(obs.point.coordinates[0])")
//                    Text("Point count: \(obs.point.coordinates[1])")
//                    Text("Accuracy: \(obs.accuracy ?? 0)")
//                    Text("Is certain \(obs.is_certain ?? false ? "true" : "false")")
//                    Text("Is escape \(obs.is_escape ?? false ? "true" : "false")")
//                    Text("Activity: \(obs.activity ?? 0)")
//                    Text("Lifestage: \(obs.lifeStage ?? 0)")
//                    Text("Method: \(obs.method ?? 0)")
//                    Text("Substrate: \(obs.substrate ?? 0)")
//                    Text("related_species: \(obs.related_species ?? 0)")
//                    Text("obscurity: \(obs.obscurity ?? 0)")
//                    Text("counting_method: \(obs.counting_method ?? 0)")
//                    Text("embargo_date: \(obs.embargo_date ?? "unknown")")
//                    Text("UUID: \(obs.uuid ?? "unknown")")
//                    Text("externalReference: \(obs.externalReference ?? "unknown")")
//                    ForEach(obs.links, id: \.self) { link in
//                        Text("link: \(link)")
//                    }
//                    ForEach(obs.details, id: \.self) { details in
//                        Text("details: \(details)")
//                    }
//                    Text("observer_location: \(obs.observer_location ?? 0)")
//                    Text("transectUUID: \(obs.transectUUID ?? "unknown")")
//                    Text("rarity: \(obs.rarity ?? 0)")

//                    Text("modified: \(obs.modified ?? "unknown")")
//                    Text("species_group: \(obs.species_group ?? 0)")
//                    Text("validation_status: \(obs.validation_status ?? "unknown")")
//                    Text("location: \(obs.location ?? 0)")
//                    Text("location_detail: \(obs.location_detail?.name ?? "unknown")")
//                    Text("Permalink: \(obs.permalink)")

//                    Text("Naar waarneming")
//                        .onTapGesture {
//                            if let url = URL(string: obs.permalink) {
//                                UIApplication.shared.open(url)
//                            }
//                        }
//                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
