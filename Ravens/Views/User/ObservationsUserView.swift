//
//  ObservationUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import SwiftyBeaver

struct ObservationsUserView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var selectedObservation: Observation?
    
    var body: some View {
        VStack {
            if let results = observationsUserViewModel.observations?.results, results.count > 0 {
                List {
                    if let results =  observationsUserViewModel.observations?.results {
                        ForEach(results
                            .sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } )
//                            .filter { result in
//                                // Add your condition here
//                                // For example, the following line filters `result` to keep only those with a specific `rarity`.
//                                // You can replace it with your own condition.
//                                ((!settings.showObsPictures) && (!settings.showObsAudio)) ||
//                                (
//                                    (result.has_photo ?? false) && (settings.showObsPictures) ||
//                                    (result.has_sound ?? false) && (settings.showObsAudio)
//                                )
//                            }
                                , id: \.id) { obs in
                            ObsUserView(
                                selectedObservation: $selectedObservation,
                                obs: obs
                            )
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ObserversView()) {
                            Label("Observers", systemImage: "list.bullet")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        
        .sheet(item: $selectedObservation) { item in
            SpeciesDetailsView(speciesID: item.species_detail.id)
        }
        
        .onAppear {
            if settings.initialUsersLoad {
                observationsUserViewModel.fetchData(
                    settings: settings,
                    userId: settings.userId,
                    completion: { log.info("viewModel.fetchData completion") })
                settings.initialUsersLoad = false
            }
        }
        .refreshable {
            log.info("refreshing")
            observationsUserViewModel.fetchData(
                settings: settings,
                userId: settings.userId,
                completion: { log.info("observationsUserViewModel.fetchdata \( settings.userId)") }
            )
        }
    }
}


struct ObservationsUserView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsUserView()
            .environmentObject(ObservationsUserViewModel())
            .environmentObject(Settings())
    }
}
