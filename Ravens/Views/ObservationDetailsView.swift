//
//  ObservationDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import SwiftUI
import SwiftyBeaver
import Popovers

struct ObservationDetailsView: View {
    let log = SwiftyBeaver.self
    
    @StateObject private var viewModel = ObservationsSpeciesViewModel(settings: Settings())
    @EnvironmentObject var settings: Settings
    
    @State private var isViewActive = false
    
    var speciesID: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            if ((viewModel.observationsSpecies?.count ?? 0) != 0) {
                HStack {
                    Image(systemName: "binoculars.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .red)
//                    Text("\(viewModel.observationsSpecies?.count ?? 0)")
//                        .foregroundColor(Color.blue)
                }
            }
        }
        
        .onAppear {
            log.info("speciesID \(speciesID)")
            viewModel.fetchData(speciesId: speciesID, limit: 1) {
                success in
                if success {
                    print("success")
                } else {
                    print("no success")
                }
                settings.isConnected = !success
            }
        }
    }
}

struct NetworkView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        if settings.isConnected {
            Text("There is a connection.")
        } else {
            Text("No xxx connection.")
        }
    }
}

struct LoginMessageView: View {
    var body: some View {
        Text("""
Sorry,
No connection with waarneming.nl
Please try to login
""")
        .padding()
        .foregroundColor(.white)
        .background(.blue)
        .cornerRadius(16)
    }
}

struct ObservationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationDetailsView(speciesID: 20)
            .environmentObject(Settings())
    }
}

