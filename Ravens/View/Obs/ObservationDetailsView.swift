//
//  ObservationDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import SwiftUI
import SwiftyBeaver
//import Popovers

struct ObservationDetailsView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var viewModel: ObservationsViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var isViewActive = false
    
    var speciesID: Int
    
    var body: some View {
            HStack() {
              if let count = viewModel.observations?.count, count > 0 {
                    Image(systemName: "binoculars.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .red)
                }
            }
            .onAppear {
                log.info("speciesID \(speciesID)")
                viewModel.fetchData(
                    settings: settings,
                    entity: .species,
                    id: speciesID,
                    completion: {
//                      isLoaded = true
                      log.info("observationsSpeciesViewModel data loaded")
                    }
                )
            }
    }
}

struct ObservationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationDetailsView(speciesID: 20)
            .environmentObject(Settings())
    }
}

