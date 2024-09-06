//
//  NotesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 05/09/2024.
//

import SwiftUI

struct NotesView: View {
    var obs: Observation // Assuming `Observation` has a `notes` property

    var body: some View {
        if !(obs.notes?.isEmpty ?? true) {
            ScrollView {
                Text(obs.notes ?? "unknown")
//                    .italic()
//                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: 300) // Set the maximum height for the scrollable area
        } else {
            EmptyView()
            .frame(maxWidth: .infinity, maxHeight: 300)
        }
    }
}



//#Preview {
//  NotesView(obs: <#Observation#>)
//}
