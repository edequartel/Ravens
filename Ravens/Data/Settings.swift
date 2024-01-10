//
//  SettingsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroup = 460
    @AppStorage("selectedRegion") var selectedRegion = 20
    @AppStorage("selectedGroup") var selectedGroup = 1
    @AppStorage("selectedGroupString") var selectedGroupString = "unknown"
//    @AppStorage("fontSize") var fontSize: Double = 16.0
}
