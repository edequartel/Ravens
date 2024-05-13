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
    @EnvironmentObject var observersViewModel: ObserversViewModel
    
    @EnvironmentObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var limit = 100
    @State private var offset = 0
    
    var locationId: Int
    var locationStr: String
    
    var body: some View {
            VStack {
                HStack {
                    CircleActionButton() {
                        presentationMode.wrappedValue.dismiss()
                    }

                    Spacer()
                    Text("Location")
                        .bold()
                    Text("\(viewModel.observations?.results.count ?? 0)x")
                        .bold()
                }
                .padding(8)
                .background(Color(hex: obsStrNorthSeaBlue))
                
                List {
                    if let results =  viewModel.observations?.results {
                        ForEach(results.sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                            result in
                            ObsView(obs: result, showLocation: true)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Info") {
                                        observersViewModel.appendRecord(
                                            name: result.user_detail?.name ?? "unknown",
                                            userID: result.user_detail?.id ?? 0)
                                        print("Like")
                                    }
                                    .tint(.blue)
                                }
                        }
                        
                    }
                }
                .padding(-10)
            }
    }
}

//struct ObservationsLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ObservationsUserView()
////            .environmentObject(ObservationsLocationViewModel(settings: Settings()))
//            .environmentObject(ObservationsLocationViewModel())
//            .environmentObject(Settings())
//    }
//}

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
