//
//  SettingsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroup = 1 //460
//    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled: Bool = false
//    @AppStorage("fontSize") var fontSize: Double = 16.0
}
