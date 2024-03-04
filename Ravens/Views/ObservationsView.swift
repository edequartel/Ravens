//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
//import MapKit

struct ObservationsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                    .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .black)
                
                Text("Results \(observationsViewModel.observations?.results.count ?? 0)/\(observationsViewModel.observations?.count ?? 0)")
                    .bold()
            }
            .padding(16)
            
            if (!keyChainViewModel.token.isEmpty) {
                List {
                    if let results = observationsViewModel.observations?.results {
                        ForEach(results.sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date) < ($0.rarity, $1.species_detail.name, $0.date) }), id: \.id) { result in
                            ObsView(obsID: result.id, showUsername: true)
                        }
                        
                    } else {
                        // Handle the case when observationsViewModel.observations?.results is nil
                        Text("nobsavaliable")
                    }
                }
            }
            Spacer()
        }

        .onAppear(){
            // Get the current locations of all the observations
            observationsViewModel.fetchData(lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                            long: settings.currentLocation?.coordinate.longitude ?? longitude
                                            )
        }
    }
}


struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ObservationsView(isShowing: .constant(false))
            .environmentObject(ObservationsViewModel(settings: Settings()))
            .environmentObject(KeychainViewModel())
            .environmentObject(Settings())
    }
}


