//
//  TestMe.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/05/2024.
//

import SwiftUI

struct ItemView: View {
    var item: Species

    var body: some View {
        Text("Details for \(item.name)")
        Text("Details for \(item.scientific_name)")
        Text("Details for \(item.rarity)")
        Text("Details for \(item.native)")
    }
}

struct TestMeView: View {
    let items: [Species] = [
            Species(species: 1, name: "Species 1", scientific_name: "Scientific 1", rarity: 1, native: true),
            Species(species: 2, name: "Species 2", scientific_name: "Scientific 2", rarity: 2, native: false),
            Species(species: 3, name: "Species 3", scientific_name: "Scientific 3", rarity: 3, native: true),
            Species(species: 4, name: "Species 4", scientific_name: "Scientific 4", rarity: 4, native: false),
            Species(species: 5, name: "Species 5", scientific_name: "Scientific 5", rarity: 5, native: true)
        ]

    
    @State private var selectedItem: Species?

    var body: some View {
        NavigationView {
            List(items) { item in
                Button(action: {
                    self.selectedItem = item
                }) {
                    Text("Tap on item \(item.name)")
                }
            }
            .navigationTitle("Items")
        }
        .sheet(item: $selectedItem) { item in
            ItemView(item: item)
        }
    }
}
