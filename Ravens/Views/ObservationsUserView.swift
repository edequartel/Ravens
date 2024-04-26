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
    
    @EnvironmentObject var viewModel: ObservationsUserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var settings: Settings
    
    @State private var explorers: [Explorer] = []
    @State private var userName: String = ""
    @State private var userId: Int = 0
    
//    @State private var messageAlert: Bool = false
//    @State private var selectedExplorer: Explorer?
    
    
    var body: some View {
//        VStack {
            HStack {
                CircleActionButton() {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Text(userName)
            }
            .padding(8)
            .background(Color(hex: obsStrNorthSeaBlue))

        
            List {
                if let results =  viewModel.observations?.results {
                    ForEach(results.sorted(by: { ($1.date, $1.time ?? "" ) < ($0.date, $0.time ?? "") } ), id: \.id) {
                        result in
                        ObsView(obs: result, showUsername: false)
                    }
                }
            }
            .padding(-10)
    }
}



//struct ObservationsUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        ObservationsUserView()
//            .environmentObject(ObservationsUserViewModel(settings: Settings()))
//            .environmentObject(Settings())
//    }
//}
