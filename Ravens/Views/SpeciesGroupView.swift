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
                ForEach(viewModel.speciesGroups, id:\.id) { speciesGroup in
                    VStack(alignment: .leading) {
                        Text("id \(speciesGroup.id)")
                        Text("region \(speciesGroup.name)")
                    }
                }
            }
            .navigationTitle("SpeciesGroups")
        }
    }
}

#Preview {
    SpeciesGroupView()
}
