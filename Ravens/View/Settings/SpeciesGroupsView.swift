//
//  SpeciesGroupsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/05/2024.
//

import SwiftUI

struct SpeciesGroupsView: View {
  @EnvironmentObject private var speciesGroupsViewModel: SpeciesGroupsViewModel

  var body: some View {
    List {
      HStack {
        Text("Id")
        Text("Name")
        Spacer()
      }
      .font(.caption)
      ForEach(speciesGroupsViewModel.speciesGroups, id:\.id) { speciesGroup in
        HStack {
          Text("\(speciesGroup.id)")
          Text("\(speciesGroup.name)")
          Spacer()
        }
        .font(.caption)
      }
    }
  }
}

#Preview {
  SpeciesGroupsView()
}
