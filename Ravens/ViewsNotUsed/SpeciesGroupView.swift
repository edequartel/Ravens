//
//  SpeciesGroupView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

struct SpeciesGroupView: View {
    @StateObject private var viewModel = SpeciesGroupViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.speciesGroups.sorted(by: {$0.id < $1.id}), id:\.id) { speciesGroup in
                    HStack() {
                        Text("\(speciesGroup.id) \(speciesGroup.name)")
//                            .foregroundColor(GroupColor(value: speciesGroup.id))
                    }
//                    .background(GroupColor(value: speciesGroup.id))
//                    .listRowBackground(GroupColor(value: speciesGroup.id))
                }
                
            }
            .navigationTitle("Species groups")
        }
    }
}

#Preview {
    SpeciesGroupView()
}
