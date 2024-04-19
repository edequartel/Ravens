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
    @EnvironmentObject var userViewModel:  UserViewModel
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
                        viewModel.fetchData(limit: limit, offset: offset, settings: settings, completion:
                                                { print("viewModel.fetchData completion") } )
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
                
                Button {
                    if offset >= 100 {
                        offset = offset - 100
                    }
                    limit = 100
                    viewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") })
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
            viewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") })
        }
    }
}

struct ObservationsUserViewExtra: View {
    let log = SwiftyBeaver.self
    
    var viewModel: ObservationsUserViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var explorers: [Int] = []
    @State private var userName: String = ""
    @State private var userId: Int = 0
    
    
    
    var body: some View {
        VStack {
            HStack() {
                Text("Observations")
                UserSimpleView()
            }
            .padding(16)
            .bold()
            Text("\(userName)")
            
            Picker("Select User", selection: $userId) {
                ForEach(explorers, id: \.self) { explorer in
                    Text("\(explorer)")
                }
                .onChange(of: userId) {
                    print("userId \(userId)")
                    settings.userId = userId
                    viewModel.fetchData(limit: 100, offset: 0, settings: settings, completion: {
                        print("viewModel.fetchData completion")
                        print(">> \(viewModel.observations?.results[0].user_detail?.name ?? "no name")")
                        userName = viewModel.observations?.results[0].user_detail?.name ?? "no name"
                    })
                }
            }
            .padding(16)
            
            List {
                if let results =  viewModel.observations?.results {
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) {
                        result in
                        ObsView(obs: result, showUsername: false)
                    }
                }
            }
        }
        .onAppear {
            settings.readExplorers(array: &explorers)
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
