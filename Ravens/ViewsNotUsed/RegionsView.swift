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
    
    @StateObject private var viewModel = RegionViewModel()
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Picker("Select a Region", selection: $settings.selectedRegion) {
            ForEach(viewModel.regions, id: \.id) { region in
                Text("\(region.name ?? "unknown")")
            }
        }
        .onChange(of: settings.selectedRegion) {
            log.verbose("selectedRegion \(settings.selectedRegion)")
        }
    }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
    }
}
