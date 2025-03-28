//
//  SwiftUIView.swift
//  Ravens
//
//  Created by Eric de Quartel on 05/09/2024.
//

import SwiftUI

struct ObsDetailsRowView: View {
  var obs: Observation
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel

  var body: some View {
    HStack {
      Image(systemName: "circle.fill")
        .foregroundColor(rarityColor(value: obs.rarity))

      if !(obs.speciesDetail.name.isEmpty) {
        Text("\(obs.speciesDetail.name)")// \(obs.species_detail.id)")
          .bold()
          .lineLimit(1) // Set the maximum number of lines to 1
          .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
      } else {
        Text("\(obs.speciesDetail.scientificName)")// \(obs.species_detail.id)")
          .bold()
          .italic()
          .lineLimit(1) // Set the maximum number of lines to 1
          .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
      }


      Spacer()
      
      if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.speciesDetail.id) {
        Image(systemSymbol: SFSpeciesFill)
          .foregroundColor(Color.gray.opacity(0.8))
      }
    }
  }
}

//#Preview {
//  ObsDetailsRowView()
//    .obs(.constant(nil))
//    .bookMarksViewModel(.constant(nil))
//}
