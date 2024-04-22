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
    
    //    var viewModel: ObservationsUserViewModel
    @EnvironmentObject var viewModel: ObservationsUserViewModel
    
    @EnvironmentObject var settings: Settings
    
    @State private var explorers: [Explorer] = []
    @State private var userName: String = ""
    @State private var userId: Int = 0
    
    @State private var messageAlert: Bool = false
    
    @State private var selectedExplorer: Explorer?
    
    
    var body: some View {
        VStack {
            VStack {
                
// DIT IS VOOR LATER MET UITBREIDING FOLLOWERS
//                Picker("Observer", selection: $selectedExplorer) {
//                    ForEach(settings.readExplorers(), id: \.id) { explorer in
//                        Text(explorer.name).tag(explorer as Explorer?)
//                    }
//                    .onChange(of: selectedExplorer) {
//                        settings.userId = selectedExplorer?.id ?? 0
//                        fetchModelData()
//                    }
//                }
                
//                Button("Delete All") {
//                    settings.explorers = nil
//                    print(userId)
//                    let explorer = Explorer(id: userId, name: userName)
//                    selectedExplorer = explorer
//                    fetchModelData()
//                    settings.addAndSaveExplorer(newExplorer: explorer)
//                }
                
//                Button("unFollow") {
//                    var explorer = selectedExplorer
//                    print(explorer?.id ?? 0)
//                    if explorer?.id != settings.userId {
//                        settings.removeAndSaveExplorer(id: explorer?.id ?? 0)
//                        let explorer = Explorer(id: settings.userId, name: userName)
//                        selectedExplorer = explorer
//                        fetchModelData()
//                    } else {
//                        messageAlert.toggle()
//                    }
//                }
                    
                
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
        
        .alert(isPresented: $messageAlert) {
            Alert(
                title: Text("Action Not Allowed"),
                message: Text("You cannot unfollow yourself."),
                dismissButton: .default(Text("OK"))
            )
        }
        
        .onAppear() {
// DIT IS VOOR LATER MET UITBREIDING FOLLOWERS
//            let explorer = Explorer(id: userId, name: userName)
////            if !settings.explorerExists(id: userId) {
//                settings.addAndSaveExplorer(newExplorer: explorer)
////            }
//            selectedExplorer = explorer
////                        fetchModelData()
        }
    }
    
    func fetchModelData() {
        viewModel.fetchData(limit: 100, offset: 0, settings: settings, completion: {
            userName = viewModel.observations?.results[0].user_detail?.name ?? "no name"
        })
        
    }
}



//struct ObservationsUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        ObservationsUserView()
//            .environmentObject(ObservationsUserViewModel(settings: Settings()))
//            .environmentObject(Settings())
//    }
//}
