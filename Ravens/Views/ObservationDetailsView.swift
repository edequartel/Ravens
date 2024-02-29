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
    
    @StateObject private var viewModel = ObservationsSpeciesViewModel(settings: Settings())
//    @StateObject private var authManager = AuthManager()
    
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            if ((viewModel.observationsSpecies?.count ?? 0) != 0) {
                HStack {
                    Image(systemName: "binoculars.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .red)
//                    Text("\(viewModel.observationsSpecies?.count ?? 0)")
//                        .foregroundColor(Color.blue)
                }
            }
        }
        
        .onAppear {
            log.info("speciesID \(speciesID)")
            viewModel.fetchData(speciesId: speciesID, limit: 1)
        }
    }
}

struct ObservationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationDetailsView(speciesID: 20)
            .environmentObject(Settings())
    }
}

