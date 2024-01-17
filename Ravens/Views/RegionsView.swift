//
//  RegionsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI

struct RegionsView: View {
    @StateObject private var viewModel = RegionViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.regions, id:\.id) { region in
                    VStack(alignment: .leading) {
                        Text("id \(region.id)")
                        Text("name \(region.name)")
                        Text("continent \(region.continent != nil ? "\(region.continent!)" : "unknown")")
                        Text("iso \(region.iso != nil ? "\(region.iso!)" : "unknown")")
                        Text("type \(region.type)")
                    }
                }
            }
            .navigationTitle("regions")
        }
    }
}

#Preview {
    RegionsView()
}


