//
//  ObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import SwiftUI
import SwiftyBeaver
import AlamofireImage

struct ObservationsSpeciesView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var viewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var speciesID: Int
    var speciesName: String
    
    var body: some View {
        VStack {
            Text("\(speciesID) \(speciesName) Total obs: \(viewModel.observationsSpecies?.count ?? 0)")
            
            //            \(viewModel.observationsSpecies?.results.count ?? 0)")
            //            Text("Locations: \(viewModel.locations.count)")
                .padding(10)
            
            
            List {
                if let results =  viewModel.observationsSpecies?.results {
                    //                    ForEach(results, id: \.id) { result in
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) { result in
                        VStack(alignment: .leading) {
                            Text("Observation ID: \(result.species)")
                                .bold()
                            Text("Species name: \(result.species_detail.name)")
                            Text("Date: \(result.date) / \(result.time ?? "unknown")")
                            //                            Text("Location: \(result.location_detail.name)")
                            Text("User: \(result.user_detail.name)")
                            Text("Location details: \(result.location_detail.name)")
                            
//                            Text("Substrate: \(result.substrate ?? 0)")
//                            Text("\(result.permalink)")
//                            Text("\(result.photos.count)")
//                            Add more details as needed
//
//                            ForEach(result.photos, id: \.self) { photo in
//                                Text("\(photo): \(photo.count)")
//                            }
                            
                            
                            ForEach(result.photos, id: \.self) { imageURLString in
                                
                                if let imageURL = URL(string: imageURLString) {
                                    AsyncImage(url: imageURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(nil, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                
                                        case .failure:
                                            Text("Failed to load image")
                                        case .empty:
                                            Text("Loading...")
                                        @unknown default:
                                            Text("<#fatalError()#>")
                                        }
                                    }
                                } else {
                                    Text("Invalid URL")
                                }
                            }
                            //
                        }
                        .onTapGesture {
                            if let url = URL(string: result.permalink) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    .font(.footnote)
                }
            }
        }
        
        .onAppear {
            log.verbose("speciesID \(speciesID)")
            viewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate, days: settings.days)
        }
        //        .padding(16)
        //        .background(Color.white.cornerRadius(18))
        //        .shadowedStyle()
        //        .padding(.horizontal, 8)
        //        .padding(.bottom, 30)
    }
}

struct ObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
//        let viewModel = ObservationsSpeciesViewModel()
//        let settings = Settings()
        ObservationsSpeciesView(speciesID: 2, speciesName: "Unknown")
            .environmentObject(ObservationsSpeciesViewModel())
            .environmentObject(Settings())
    }
}



//            List {
//                if let results =  viewModel.observationsSpecies?.results {
//                    ForEach(results, id: \.id) { result in
//                        VStack(alignment: .leading) {
//                            Text("Observation ID: \(result.species)")
//                            Text("Species name: \(result.species_detail.name)")
//                            Text("Date: \(result.date)")
//                            Text("Location: \(result.location_detail.name)")
//                            Text("User: \(result.user_detail.name)")
//                            Text("Time: \(result.time ?? "unknown")")
//                            Text("Substrate: \(result.substrate ?? 0)")
//                            // Add more details as needed
//                        }
//                        .onTapGesture {
//                            if let url = URL(string: result.permalink) {
//                                UIApplication.shared.open(url)
//                            }
//                        }
//                    }
//
//                    .font(.footnote)
//                }
//            }
