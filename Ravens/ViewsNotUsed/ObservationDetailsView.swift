//
//  ObservationDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct ObservationDetailsView: View {
    let log = SwiftyBeaver.self
    
    @StateObject private var viewModel = ObservationsSpeciesViewModel()
    
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            if ((viewModel.observationsSpecies?.count ?? 0) != 0) {
                Text("Obs \(viewModel.observationsSpecies?.count ?? 0)")
                    .foregroundColor(Color.blue)
            }
        }
        
        .onAppear {
            log.verbose("speciesID \(speciesID)")
            viewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate, days: settings.days)
        }
    }
}

struct ObservationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = Settings()
        ObservationDetailsView(speciesID: 20)
//            .environmentObject(settings)
    }
}

