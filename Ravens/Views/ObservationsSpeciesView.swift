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
    @Environment(\.presentationMode) var presentationMode
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var speciesID: Int
    var speciesName: String
    
    @State private var isSheetPresented = false
    @State private var endOfListReached = false
    
    let monthlyViews: [Double] = [120, 150, 80, 200, 100, 180, 250, 300, 160, 120, 200, 180]
    
    var body: some View {
        ZStack {
            VStack {
                Button {
                    isSheetPresented.toggle()
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("\(speciesName) - \(viewModel.observationsSpecies?.count ?? 0)x")
                            .font(.headline)
                    }
                }
                .padding(16)
                .bold()
                .buttonStyle(.bordered)
                .foregroundColor(.obsGreenEagle)
                
                if endOfListReached {
                    EndOfListObsView()
                }
                
                //            YearView(monthlyViews: monthlyViews)
                //                .padding(16)
                
                List {
                    if let results = viewModel.observationsSpecies?.results {
                        let sortedResults = results.sorted(by: { ($1.date, $0.time ?? "" ) < ($0.date, $1.time ?? "") })
                        ForEach(sortedResults.indices, id: \.self) { index in
                            let result = sortedResults[index]
                            
                            ObsView(obs: result)
                                .onAppear {
                                    if index == sortedResults.count - 1 {
                                        endOfListReached = true
                                        
                                        // Perform any action you want when the end of the list is reached here
                                        //viewModel.fetchData(speciesId: speciesID, limit: 100, date: settings.selectedDate, days: settings.days) <<< deze wijzige met 0 and 100
                                    }
                                }
                        }
                    }
                }
            }
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .topLeft()
        }
//        .sheet(isPresented: $isSheetPresented) {
//                    SpeciesDetailsView(speciesID: speciesID)
//                }
    }
}


struct ObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsSpeciesView(speciesID: 2, speciesName: "Unknown")
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}

