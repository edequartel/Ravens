//
//  NotesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 05/09/2024.
//

import SwiftUI

struct NotesView: View {
  var obs: Obs // Assuming `Observation` has a `notes` property

  var body: some View {
    if !(obs.notes?.isEmpty ?? true) {
      Text(obs.notes ?? "unknown")
        .padding(2)  // Adds padding around the text
        .frame(maxWidth: .infinity, alignment: .leading)  // Ensures the text aligns to the left
        .multilineTextAlignment(.leading)  // Aligns text within the Text view
    } else {
      EmptyView()
    }
  }
}
