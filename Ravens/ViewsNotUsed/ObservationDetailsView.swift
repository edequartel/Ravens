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
    @StateObject private var authManager = AuthManager()
    
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            if ((viewModel.observationsSpecies?.count ?? 0) != 0) {
//                Text("Obs \(viewModel.observationsSpecies?.count ?? 0)")
//                    .foregroundColor(Color.blue)
                Image(systemName: "binoculars.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue, .red)
            }
        }
        
        .onAppear {
            log.verbose("speciesID \(speciesID)")
            viewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate, days: settings.days, token: authManager.token ?? "noToken")
        }
    }
}

struct ObservationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationDetailsView(speciesID: 20)
            .environmentObject(Settings())
    }
}

