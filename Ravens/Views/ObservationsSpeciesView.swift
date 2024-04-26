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
    
    
    var body: some View {
//            VStack {
                HStack {
                    CircleActionButton() {
                        presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button {
                        isSheetPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("\(speciesName) - \(viewModel.observationsSpecies?.count ?? 0)x")
                                .font(.headline)
                                .lineLimit(1) // Limit text to a single line
                                .truncationMode(.tail) // Add an ellipsis when the text is too long
                                
                        }
                    }
//                    .bold()
                    .buttonStyle(.bordered)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                }
                .padding(8)
                .background(Color(hex: obsStrNorthSeaBlue))
                
                if endOfListReached {
                    EndOfListObsView()
                }
                
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
//                .padding(0)
//            }
        .sheet(isPresented: $isSheetPresented) {
                    SpeciesDetailsView(speciesID: speciesID)
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

