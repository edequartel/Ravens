//
//  TabSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct TabSpeciesView: View {
    @State private var showFirstView = false
    
    var item: Species
    
    var body: some View {
        NavigationView {
            VStack {
                if showFirstView {
//                    MapObservationsSpeciesView(item: item)
                    Text("MapObservationsSpeciesView")
                } else {
                    ObservationsSpeciesView(item: item)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showFirstView.toggle()
                }) {
                    Image(systemName: "rectangle.2.swap") // Replace with your desired image
                }
            }
        }
    }
}


//struct TabSpeciesView_Previews: PreviewProvider {
//    static var previews: some View {
//        let testSpecies = Species(species: 65, name: "name", scientific_name: "scientific", rarity: 1, native: true)// Initialize this with the appropriate values
//        TabSpeciesView(item: testSpecies)
//    }
//}


