////
////  RegionView.swift
////  Ravens
////
////  Created by Eric de Quartel on 08/01/2024.
////
//
//import SwiftUI
//
//struct RegionListsView: View {
//    @EnvironmentObject private var viewModel: RegionListViewModel
//    
//    var body: some View {
//        NavigationView {
//            List {
//                HStack() {
//                    Text("Id")
//                    Text("Region")
//                    Text("Species group")
//                    Spacer()
//                }
//                .font(.caption)
//                ForEach(viewModel.regionLists.sorted(by: {
//                    if $0.region != $1.region {
//                        return $0.region < $1.region
//                    } else {
//                        return $0.species_group < $1.species_group
//                    }
//                }), id:\.id) { region in
//                    HStack() {
//                        Text("\(region.id)")
//                        Text("\(region.region)")
//                        Text("\(region.species_group)")
//                        Spacer()
//                    }
//                    .font(.caption)
//                }
//            }
//        }
//    }
//}
//
//
//
//#Preview {
//    RegionListsView()
//}
//
