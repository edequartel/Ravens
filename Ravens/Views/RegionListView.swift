//
//  RegionView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

struct RegionListView: View {
    @StateObject private var viewModel = RegionListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.regionLists, id:\.id) { region in
                    VStack(alignment: .leading) {
                        Text("Id \(region.id)")
                        Text("Region \(region.region)")
                        Text("Group \(region.species_group)")
                    }
                }
            }
            .navigationTitle("Region lists")
        }
    }
}



#Preview {
    RegionListView()
}

