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
    
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settings: Settings
    
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
            log.info("refreshing")
            observationsUserViewModel.fetchData(
                language: settings.selectedLanguage,
                userId: settings.userId,
                completion: { log.error("**observationsUserViewModel.fetchdata \( settings.userId)") }
            )
        }
    }
}


struct ObservationsUserView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsUserView()
            .environmentObject(ObservationsUserViewModel())
            .environmentObject(Settings())
    }
}


//userViewModel.fetchUserData(
//    completion: {
//        log.info("1. userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
//        isUserDataLoaded = true
//        settings.userId = userViewModel.user?.id ?? 0
//        settings.userName = userViewModel.user?.name ?? ""
//        
//        observationsUserViewModel.fetchData(
//            language: settings.selectedLanguage,
//            userId: userViewModel.user?.id ?? 0,
//            completion: {
//                log.info("2. userViewModel data loaded")
//                isObservationsUserDataLoaded = true
//                checkDataLoaded()
//            })
//    })
