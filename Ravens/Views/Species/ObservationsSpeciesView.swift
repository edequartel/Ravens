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
    
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var item: Species
    
    @State private var endOfListReached = false
    @State private var showingDetails = false
    
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(Color(myColor(value: item.rarity)))
                Text("\(item.name)")// - \(item.id)")
                    .bold()
                    .lineLimit(1) // Set the maximum number of lines to 1
                    .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                Spacer()
                
                
                if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) {
                    Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) ? "star.fill" : "star")
                }
                
                NavigationLink(destination: SpeciesDetailsView(speciesID: item.id)
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarHidden(true),
                               label: {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                })
                

            }
            VStack {
                HStack {
                    Text(speciesViewModel.findSpeciesByID(speciesID: item.id) ?? "noName")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Spacer()
                }
                HStack{
                    Text("\(item.scientific_name)")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .italic()
                        .lineLimit(1) // Set the maximum number of lines to 1
                        .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                    Spacer()
                }
            }
            
            
        }
        
        .padding()
        
        List {
            if let results = observationsSpeciesViewModel.observationsSpecies?.results {
                let sortedResults = results.sorted(by: { ($1.date, $0.time ?? "" ) < ($0.date, $1.time ?? "") })
                ForEach(sortedResults.indices, id: \.self) { index in
                    let result = sortedResults[index]
                    
                    ObsSpeciesView(obs: result)
                        .onAppear {
                            if index == sortedResults.count - 1 {
                                endOfListReached = true
                            }
                        }
                }
            }
            
        }
        
        .refreshable {
            print("refreshing...")
            fetchDataModel()
        }
        
        .onAppear() {
            if settings.initialSpeciesLoad {
                fetchDataModel()
                settings.initialSpeciesLoad = false
            }
        }
    }
    
    func fetchDataModel() {
        observationsSpeciesViewModel.fetchData(
            settings: settings,
            speciesId: item.id,
            limit: 100,
            offset: 0
        )
    }
}


struct ObservationsSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        let testSpecies = Species(species: 62, name: "Unknown", scientific_name: "Scientific name", rarity: 1, native: true)
        ObservationsSpeciesView(item: testSpecies)
            .environmentObject(ObservationsSpeciesViewModel())
            .environmentObject(Settings())
    }
}

