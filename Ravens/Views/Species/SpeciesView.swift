//
//  TabSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct SpeciesView: View {
    @State private var showFirstView = false
    @State private var isPresented = false
    @State private var isPresented1 = false

    @EnvironmentObject var settings: Settings


    var item: Species
    @Binding var selectedSpecies: Species?
    @Binding var selectedObservationSound: Observation?
    @Binding var selectedObs: Observation?

    @Binding var imageURLStr: String?


    var body: some View {
//        NavigationView {
            VStack {
                if showView { Text("SpeciesView").font(.customTiny) }
                if showFirstView && !settings.accessibility {
                    MapObservationsSpeciesView(item: item)
                } else {
                  ObservationsSpeciesView(
                    item: item,
                    selectedSpecies: $selectedSpecies,
                    selectedObservationSound: $selectedObservationSound,
                    selectedObs: $selectedObs,
                    imageURLStr: $imageURLStr)
                }
            }
//        }

        .toolbar {
            if !settings.accessibility {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFirstView.toggle()
                    }) {
                        Image(systemName: "rectangle.2.swap") // Replace with your desired image
                    }
                }
            }

            if !settings.accessibility {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        settings.hidePictures.toggle()
                    }) {
                        ImageWithOverlay(systemName: "photo", value: !settings.hidePictures)
                    }
                }
            }
        }
        .onAppear() {
            settings.initialSpeciesLoad = true
        }
    }
}


//struct TabSpeciesView_Previews: PreviewProvider {
//    static var previews: some View {
//        let testSpecies = Species(species: 65, name: "name", scientific_name: "scientific", rarity: 1, native: true)// Initialize this with the appropriate values
//        TabSpeciesView(item: testSpecies)
//    }
//}


