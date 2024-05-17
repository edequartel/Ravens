//
//  ObservationUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import SwiftyBeaver

struct ObservationsUserViewExtra: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var explorers: [Explorer] = []
    @State private var userName: String = ""
    @State private var userId: Int = 0
    
    
    @State private var limit = 100
    @State private var offset = 0
    
    @State private var start = 0
    @State private var end = 100
    
    
    var body: some View {
        VStack {
            List {
                if let results =  observationsUserViewModel.observations?.results {
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) {
                        result in
                        ObsUserView(obs: result)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ObserversView()) {
                        Label("Observers", systemImage: "person.2.fill")
                    }
                }
                
                ToolbarItem() {
                    HStack {
//                        Text("Observer")
                        Text("\(settings.userName)")
                    }
                }
            }
        }
        .onAppear {
            observationsUserViewModel.fetchData(limit: limit, offset: offset, settings: settings, completion: { print("viewModel.fetchData completion") })
        }
    }
}


struct ObservationsUserViewExtra_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsUserViewExtra()
            .environmentObject(ObservationsUserViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}
