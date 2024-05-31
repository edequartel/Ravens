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
    
    @State private var userName: String = ""
    @State private var userId: Int = 0
    
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
                        Label("Observers", systemImage: "list.bullet")
                    }
                }
            }
        }
        .refreshable {
            print("refreshing")
            observationsUserViewModel.fetchData(
                //limit: observationsUserViewModel.limit,
                //offset: observationsUserViewModel.offset,
                language: settings.selectedLanguage,
                userId: settings.userId,
                completion: { print("viewModel.fetchData completion")
                })
        }
        .onAppear {
            observationsUserViewModel.fetchData(
                //limit: observationsUserViewModel.limit,
                //offset: observationsUserViewModel.offset,
                language: settings.selectedLanguage,
                userId: settings.userId, <-hier the user?.id gebruiken van een eerder model, eerder deze userId setten bij start
                completion: { print("viewModel.fetchData completion")
                })
        }
    }
}


struct ObservationsUserViewExtra_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsUserViewExtra()
            .environmentObject(ObservationsUserViewModel())
            .environmentObject(Settings())
    }
}
