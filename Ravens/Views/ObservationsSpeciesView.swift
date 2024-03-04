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
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var speciesID: Int
    var speciesName: String
    
    @State private var isSheetPresented = false
    
    var body: some View {
        VStack {
            Button("\(speciesName) - \(viewModel.observationsSpecies?.count ?? 0)x") {
                isSheetPresented.toggle()
            }
            .padding()
            .buttonStyle(.bordered)
            .foregroundColor(.obsGreenEagle)

            List {
                if let results =  viewModel.observationsSpecies?.results {
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) {
                        result in
                        ObsView(obsID: result.id ?? 0) //
                    }
                    .font(.footnote)
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
                    SpeciesDetailsView(speciesID: speciesID)
                }
        .onAppear {
            log.verbose("speciesID \(speciesID)")
            viewModel.fetchData(speciesId: speciesID, limit: 100) 
        }
    }
}


struct ObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsSpeciesView(speciesID: 2, speciesName: "Unknown")
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}

