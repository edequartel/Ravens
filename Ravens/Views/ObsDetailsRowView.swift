//
//  SwiftUIView.swift
//  Ravens
//
//  Created by Eric de Quartel on 05/09/2024.
//

import SwiftUI

struct ObsDetailsRowView: View {
  var obs: Observation
  var bookMarksViewModel: BookMarksViewModel
  
  var body: some View {
    HStack {
      Image(systemName: "circle.fill")
        .foregroundColor(RarityColor(value: obs.rarity))
      
      Text("\(obs.species_detail.name)")// \(obs.species_detail.id)")
        .bold()
        .lineLimit(1) // Set the maximum number of lines to 1
        .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
      
//      if obs.photos?.count ?? 0 > 0 {
//        Image(systemName: "photo")
//      }
      
      if obs.sounds?.count ?? 0 > 0 {
        Image(systemName: "waveform")
      }
      
      if obs.notes?.count ?? 0 > 0 {
        Image(systemName: "list.clipboard")
      }
      Spacer()
      if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
        Image(systemName: SFSpeciesFill)
      }
    }
  }
}

//#Preview {
//  ObsDetailsRowView()
//    .obs(.constant(nil))
//    .bookMarksViewModel(.constant(nil))
//}
