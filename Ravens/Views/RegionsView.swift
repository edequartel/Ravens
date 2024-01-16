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
                        Text("id".localized() + "\(region.id)")
                        Text("name".localized() + "\(region.name)")
                        Text("continent".localized() + "\(region.continent != nil ? "\(region.continent!)" : "unknown".localized())")
                        Text("iso".localized() + "\(region.iso != nil ? "\(region.iso!)" : "unknown".localized())")
                        Text("type".localized() + "\(region.type)")
                    }
                }
            }
            .navigationTitle("regions".localized())
        }
    }
}

#Preview {
    RegionsView()
}


