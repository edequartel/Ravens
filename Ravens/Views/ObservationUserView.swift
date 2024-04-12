//
//  ObservationUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import SwiftyBeaver


struct ObservationsUserView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var viewModel: ObservationsUserViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var limit = 100
    @State private var offset = 0
    
    var body: some View {
        VStack {
            HStack() {
                Text("Waarnemingen"+" ")
                UserSimpleView()
                
                Button {
                    if let maxOffset = viewModel.observations?.count {
                        offset = min(offset + 100, maxOffset)
                        limit = 100
                        viewModel.fetchData(limit: limit, offset: offset)
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
                
                Button {
                    if offset >= 100 {
                        offset = offset - 100
                    }
                    limit = 100
                    viewModel.fetchData(limit: limit, offset: offset)
                } label: {
                    Image(systemName: "minus.circle")
                }
                
                Text("\(offset)")
            }
            .padding()
            
            List {
                if let results =  viewModel.observations?.results {
                    ForEach(results.sorted(by: { (/*$0.species_group, */$1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < (/*$1.species_group, */$0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                        result in
                        ObsView(obs: result)
                    }
                    .font(.footnote)
                }
            }
        }
        .onAppear {
            viewModel.fetchData(limit: limit, offset: offset)
        }
    }
}

struct ObservationsUserViewExtra: View {
    let log = SwiftyBeaver.self
    
    var viewModel: ObservationsUserViewModel
    @EnvironmentObject var settings: Settings
    
    
    var body: some View {
        VStack {
            HStack() {
                Text("Observations")
                UserSimpleView()
            }
            .padding(16)
            .bold()
            
            List {
                if let results =  viewModel.observations?.results {
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) {
                        result in
                        ObsView(obs: result, showUsername: false)
                    }
                }
            }
        }
    }
}



struct ObservationsUserView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsUserView()
            .environmentObject(ObservationsUserViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}
