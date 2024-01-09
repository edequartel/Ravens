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
                        Text("id \(region.id)")
                        Text("region \(region.region)")
                        Text("group \(region.species_group)")
                    }
                }
            }
            .navigationTitle("Region-Lists")
        }
        .onAppear(){
            viewModel.fetchData()
        }
    }
}



#Preview {
    RegionListView()
}

