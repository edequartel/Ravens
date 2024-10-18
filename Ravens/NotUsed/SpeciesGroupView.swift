//
//  SpeciesGroupView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

struct SpeciesGroupView: View {
    @EnvironmentObject private var speciesGroupsviewModel: SpeciesGroupsViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(speciesGroupsviewModel.speciesGroups.sorted(by: {$0.id < $1.id}), id:\.id) { speciesGroup in
                    HStack() {
                        Text("\(speciesGroup.id) \(speciesGroup.name)")
                    }
                }
                
            }
            .navigationTitle("Species groups")
        }
    }
}

#Preview {
    SpeciesGroupView()
}
