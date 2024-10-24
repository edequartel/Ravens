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
    
    @StateObject private var viewModel = RegionViewModel(settings: Settings())
    @EnvironmentObject var settings: Settings
    
    var onChange: (() -> Void)?
    
    var body: some View {
        Picker("Select a Region", selection: $settings.selectedRegion) {
            ForEach(viewModel.regions, id: \.id) { region in
                Text("\(region.name )")
            }
        }
        .onChange(of: settings.selectedRegion) {
            log.verbose("selectedRegion \(settings.selectedRegion)")
            onChange?()
        }
    }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
            .environmentObject(Settings())
    }
}
