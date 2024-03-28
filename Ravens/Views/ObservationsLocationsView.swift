//
//  ObservationsLocationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import SwiftUI
import SwiftyBeaver


struct ObservationsLocationView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var viewModel: ObservationsLocationViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var limit = 100
    @State private var offset = 0
    
    @Binding var locationId: Int
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack() {
                HStack {
                    Text("Obs")
                    Spacer()
                    Text("Area")
                }
                Spacer()
                Text(String(locationId))
                
//                Button {
//                    if let maxOffset = viewModel.observationsSpecies?.count {
//                        offset = min(offset + 100, maxOffset)
//                        limit = 100
//                        viewModel.fetchData(locationId: locationId, limit: limit, offset: offset)
//                    }
//                } label: {
//                    Image(systemName: "plus.circle")
//                }
//                
//                Button {
//                    if offset >= 100 {
//                        offset = offset - 100
//                    }
//                    limit = 100
//                    viewModel.fetchData(locationId: locationId, limit: limit, offset: offset)
//                } label: {
//                    Image(systemName: "minus.circle")
//                }
//                
//                Text("\(offset)")
            }
            .padding()
            
            List {
                if let results =  viewModel.observationsSpecies?.results {
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) {
                        result in
                        ObsView(obsID: result.id ?? 0, showUsername: true)
                    }
                    .font(.footnote)
                }
            }
        }
        .onAppear {
            viewModel.fetchData(locationId: locationId, limit: limit, offset: offset, completion: { print("fetchData ObservationsLocationViewc completed") })
        }
    }
}

struct ObservationsLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsUserView()
            .environmentObject(ObservationsLocationViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}
