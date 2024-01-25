//
//  ObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct ObservationsSpeciesView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var viewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int
    
    var body: some View {
        VStack {
//            Text("\(speciesID) Total: \(viewModel.observationsSpecies?.count ?? 0) \(viewModel.observationsSpecies?.results.count ?? 0)")
//            Text("Locations: \(viewModel.locations.count)")
            
            List {
                if let results =  viewModel.observationsSpecies?.results {
                    ForEach(results, id: \.id) { result in
                        VStack(alignment: .leading) {
                            Text("Observation ID: \(result.species)")
                            Text("Species name: \(result.species_detail.name)")
                            Text("Date: \(result.date)")
                            Text("Location: \(result.location_detail.name)")
                            Text("User: \(result.user_detail.name)")
                            Text("Time: \(result.time ?? "unknown")")
                            Text("Substrate: \(result.substrate ?? 0)")
                            // Add more details as needed
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
        .padding(16)
        .background(Color.white.cornerRadius(18))
        .shadowedStyle()
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
    }
}

struct ObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ObservationsSpeciesViewModel()
        let settings = Settings()
        ObservationsSpeciesView(speciesID: 32)
            .environmentObject(viewModel)
            .environmentObject(settings)
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
