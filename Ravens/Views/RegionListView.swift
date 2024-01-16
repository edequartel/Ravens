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
                        Text("id".localized() + "\(region.id)")
                        Text("region".localized() + "\(region.region)")
                        Text("group".localized() + "\(region.species_group)")
                    }
                }
            }
            .navigationTitle("regionlists".localized())
        }
    }
}



#Preview {
    RegionListView()
}

