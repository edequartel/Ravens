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
                ForEach(viewModel.regionLists.sorted(by: {$0.region < $1.region}), id:\.id) { region in
                    HStack() {
                        Text("Id \(region.id)")
                        Text("Region \(region.region)")
                        Text("Group \(region.species_group)")
                        Spacer()
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

