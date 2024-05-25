//
//  RegionsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct RegionsView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject private var regionsViewModel: RegionsViewModel
//    @EnvironmentObject var settings: Settings

    var body: some View {
//        Picker("Select a Region", selection: $settings.selectedRegion) {
//            ForEach(viewModel.regions, id: \.id) { region in
//                Text("\(region.id)")
//                Text("\(region.name)")//.tag(region.id)
//            }
//        }
//        .onChange(of: settings.selectedRegion) {
//            log.error("selectedRegion \(settings.selectedRegion)")
//        }
        
        NavigationView {
            List {
                HStack {
                    Text("id")
                    Text("type")
                    Text("name")//.tag(region.id)
                    Text("continent")//.tag(region.id)
                    Spacer()
    //                        Text("\(region.iso ?? "unknown")")//.tag(region.id)
                }
                .font(.caption)
                ForEach(regionsViewModel.regions, id: \.id) { region in
                    HStack {
                        Text("\(region.id)")
                        Text("\(region.type)")//.tag(region.id)
                        Text("\(region.name)")//.tag(region.id)
                        Text("\(region.continent ?? 0)")//.tag(region.id)
//                        Text("\(region.iso ?? "unknown")")//.tag(region.id)
                        Spacer()
                    }
                    .font(.caption)
                }
            }
        }
    }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
            .environmentObject(Settings())
    }
}
