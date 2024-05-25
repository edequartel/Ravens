//
//  SpeciesGroupsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/05/2024.
//

import SwiftUI

struct SpeciesGroupsView: View {
    @EnvironmentObject private var speciesGroupViewModel: SpeciesGroupViewModel
    
    var body: some View {
        NavigationView {
            List {
                HStack() {
                    Text("Id")
                    Text("Name")
                    Spacer()
                }
                .font(.caption)
                ForEach(speciesGroupViewModel.speciesGroups, id:\.id) { speciesGroup in
                    HStack() {
                        Text("\(speciesGroup.id)")
                        Text("\(speciesGroup.name)")
//                        Text("\(speciesGroup.species_group)")
                        Spacer()
                    }
                    .font(.caption)
                }
            }
        }
    }
}





#Preview {
    SpeciesGroupsView()
}
