//
//  ObservationDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import SwiftUI
import SwiftyBeaver
import Popovers

struct ObservationDetailsView: View {
    let log = SwiftyBeaver.self
    
    @StateObject private var viewModel = ObservationsSpeciesViewModel(settings: Settings())
    @EnvironmentObject var settings: Settings
    
    @State private var isViewActive = false
    
    var speciesID: Int
    
    var body: some View {
            HStack() {
                if let count = viewModel.observationsSpecies?.count, count > 0 {
                    Image(systemName: "binoculars.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .red)
//                    Spacer(minLength:2)
//                    Text("\(count)")
//                        .foregroundColor(.blue)
                }
            }
            .onAppear {
                log.info("speciesID \(speciesID)")
                viewModel.fetchData(speciesId: speciesID, limit: 1, date: settings.selectedDate, days: settings.days
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

