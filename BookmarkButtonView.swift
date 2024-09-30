//
//  SwiftUIView.swift
//  Ravens
//
//  Created by Eric de Quartel on 30/09/2024.
//

import SwiftUI

struct BookmarkButtonView: View {
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    var speciesID: Int

    var body: some View {
        Button(action: {
            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) {
                bookMarksViewModel.removeRecord(speciesID: speciesID)
            } else {
                bookMarksViewModel.appendRecord(speciesID: speciesID)
            }
        }) {
            Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) ? SFSpeciesFill : SFSpecies)
        }
    }
}

struct BookmarkButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock BookMarksViewModel
        let mockBookMarksViewModel = BookMarksViewModel()

        // Provide a speciesID
        let speciesID = 2

        // Return the BookmarkButtonView with the mock data
        BookmarkButtonView(speciesID: speciesID)
            .environmentObject(mockBookMarksViewModel)
    }
}

