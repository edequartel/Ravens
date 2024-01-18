//
//  ObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import SwiftUI

struct ObservationsSpeciesView: View {
    @EnvironmentObject var viewModel: ObservationsSpeciesViewModel

    @EnvironmentObject var settings: Settings
    
    var speciesID: Int
    
    var body: some View {
        NavigationStack {
            List {
                if let results =  viewModel.observationsSpecies?.results {
                    ForEach(results, id: \.id) { result in
                        VStack(alignment: .leading) {
                            Text("Observation ID: \(result.species)")
                            Text("Species name: \(result.species_detail.name)")
                            Text("Date: \(result.date)")
                            Text("\(result.location_detail.name)")
                            Text("Date: \(result.user_detail.name)")
                            // Add more details as needed
                        }
                    }
                    .font(.footnote)
                }
            }
            .onAppear {
                viewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate)
            }
            .navigationBarTitle("Observations Species")
        }
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

