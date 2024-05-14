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
    
    var item: Species
    
    @State private var isSheetPresented = false
    @State private var endOfListReached = false
    
    
    var body: some View {
        VStack() {            
            
            List {
                if let results = viewModel.observationsSpecies?.results {
                    let sortedResults = results.sorted(by: { ($1.date, $0.time ?? "" ) < ($0.date, $1.time ?? "") })
                    ForEach(sortedResults.indices, id: \.self) { index in
                        let result = sortedResults[index]
                        
                        ObsView(obs: result)
                            .onAppear {
                                if index == sortedResults.count - 1 {
                                    endOfListReached = true
                                }
                            }
                    }
                }
            }
        }
        .onAppear() {
            fetchDataModel()
        }
    }
    
    func fetchDataModel() {
        viewModel.fetchData(
            speciesId: item.id,
            limit: 100,
            offset: 0,
            date: settings.selectedDate,
            days: settings.days
        )
    }
}


struct ObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        let testSpecies = Species(species: 62, name: "Unknown", scientific_name: "Scientific name", rarity: 1, native: true)
        ObservationsSpeciesView(item: testSpecies)
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}

