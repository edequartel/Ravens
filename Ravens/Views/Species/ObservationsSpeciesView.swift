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
    @EnvironmentObject var htmlViewModel: HTMLViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var item: Species
    
    @State private var endOfListReached = false
    @State private var isLoaded = false
    @State private var selectedObservation: Observation?
    
    @State private var soundsWrapper: SoundArrayWrapper? = nil
    
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: htmlViewModel.speciesScientificNameExists(item.scientific_name) ? "circle.hexagonpath.fill" : "circle.fill")
                    .foregroundColor(RarityColor(value: item.rarity))
                Text("\(item.name)")// - \(item.id)")
                    .bold()
                    .lineLimit(1) // Set the maximum number of lines to 1
                    .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
                Spacer()
                
                Button(action: {
                    if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) {
                        print("bookmarks remove")
                        bookMarksViewModel.removeRecord(speciesID: item.id)
                    } else {
                        bookMarksViewModel.appendRecord(speciesID: item.id)
                        print("bookmarks append")
                    }
                    
                } ) {
                    Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) ? SFSpeciesFill : SFSpecies)
                        .foregroundColor(.black)
                }
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
        .padding(.horizontal,10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("""
                             \(item.name)
                             \(bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) ? "favorite": "not favorite")
                             \(speciesViewModel.findSpeciesByID(speciesID: item.id) ?? "noName")
                             \(item.scientific_name)
                            """
        )
        
        
        HorizontalLine()
        
        //        if !isLoaded { ProgressView()
        //        } else
        //        VStack {
        List {
            if let results = observationsSpeciesViewModel.observationsSpecies?.results {
                let sortedResults = results.sorted(by: { ($1.date, $0.time ?? "" ) < ($0.date, $1.time ?? "") })
                ForEach(sortedResults.indices, id: \.self) { index in
                    let obs = sortedResults[index]
                    ObsSpeciesView(
                        obs: obs
                    )
                    
                    .accessibilityLabel("\(obs.species_detail.name) \(obs.date) \(obs.time ?? "")")
                    
                    .onTapGesture(count: 2) {
                        if let sounds = obs.sounds, !sounds.isEmpty {
                            soundsWrapper = SoundArrayWrapper(sounds: sounds)
                            vibrate()
                        }
                    }
                    
                }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            print("refreshing...")
            fetchDataModel()
        }
        .sheet(item: $selectedObservation) { item in
            SpeciesDetailsView(speciesID: item.species_detail.id)
        }
        
        .sheet(item: $soundsWrapper) { wrapper in
            PlayerControlsView(audio: wrapper.sounds)
                .presentationDetents([.fraction(0.2), .medium, .large])
                .presentationDragIndicator(.visible)
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
            offset: 0,
            completion: {
                isLoaded = true
                log.info("observationsSpeciesViewModel data loaded")
            }
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

