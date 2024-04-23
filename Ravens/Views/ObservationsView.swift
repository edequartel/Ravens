//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI


struct ObservationsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    
    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var settings: Settings
//    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                        .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .black)
                    
                    Text("Radius")
                        .bold()
                    Text("\(observationsViewModel.observations?.results.count ?? 0)x")
                        .bold()
                }
                .padding(16)
                
                if (!keyChainViewModel.token.isEmpty) {
                    List {
                        if let results = observationsViewModel.observations?.results {
                            ForEach(results.sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                                result in
                                ObsView(obs: result, showUsername: false)
                            }
                        } else {
                            Text("nobsavaliable")
                        }
                    }
                }
                Spacer()
            }
            
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .topLeft()
            
        }
    }
}


struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ObservationsView()
            .environmentObject(ObservationsViewModel())
            .environmentObject(KeychainViewModel())
//            .environmentObject(Settings())
    }
}


