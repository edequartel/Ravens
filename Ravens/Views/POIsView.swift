//
//  POIsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 28/03/2024.
//

import SwiftUI

struct POIsView: View {
    @ObservedObject var viewModel = POIViewModel()

    var body: some View {
        List(viewModel.POIs, id: \.name) { poi in
            VStack(alignment: .leading) {
                Text(poi.name)
                Text("Latitude: \(poi.coordinate.latitude)")
                Text("Longitude: \(poi.coordinate.longitude)")
            }
        }
        .onAppear {
            viewModel.fetchPOIs()
        }
    }
}

#Preview {
    POIsView()
}
