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
            .frame(maxHeight: 400) // Set the maximum height for the scrollable area
        } else {
            EmptyView()
            .frame(maxHeight: 400)
        }
    }
}



//#Preview {
//  NotesView(obs: <#Observation#>)
//}
