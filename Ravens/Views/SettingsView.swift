//
//  SettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = BirdViewModel()
    
    @State private var selectedGroup = 460
    
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Picker("Group", selection: $selectedGroup) {
                    Text("Birds").tag(6)
                    Text("Algea and Weeds").tag(460)
                }
                .onChange(of: selectedGroup) {
                    viewModel.fetchData(for: selectedGroup)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
