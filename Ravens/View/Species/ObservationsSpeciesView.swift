//
//  ObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct ObservationsSpeciesView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var speciesViewModel: SpeciesViewModel
//  @EnvironmentObject var htmlViewModel: HTMLViewModel
  @EnvironmentObject var settings: Settings

  @State private var hasAppeared = false

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0

  var item: Species

  @State private var offset = 0
  @State private var endOfListReached = false
  @State private var isLoaded = false

  @Binding var selectedSpeciesID: Int?


  var body: some View {
    VStack {
      VStack {
        if showView { Text("ObservationsSpeciesView").font(.customTiny) }

        HStack {
          Image(systemSymbol: .circleFill)
            .uniformSize()
            .foregroundColor(rarityColor(value: item.rarity))

          Text("\(item.name)")
            .bold()
            .lineLimit(1) // Set the maximum number of lines to 1
            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
          Spacer()

          Button(action: {
//            selectedSpeciesID = item.id
            selectedSpeciesID = item.species_id
          }  ) { Image(systemSymbol: .infoCircle)
              .uniformSize()
          }

          Button(action: {
            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.species_id) {
              print("bookmarks remove")
              bookMarksViewModel.removeRecord(speciesID: item.species_id)
            } else {
              bookMarksViewModel.appendRecord(speciesID: item.species_id)
              print("bookmarks append")
            }

          } ) {
            Image(systemSymbol: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.species_id) ? SFSpeciesFill : SFSpecies)
              .uniformSize()
//              .foregroundColor(.black)
          }

        }

        VStack {
          HStack {
            Text(speciesViewModel.findSpeciesByID(speciesID: item.species_id) ?? "noName")
              .foregroundColor(.gray)
              .font(.footnote)
            Spacer()
          }
          HStack{
            Text("\(item.scientific_name)")
              .foregroundColor(.gray)
              .font(.footnote)
              .italic()
              .lineLimit(1) // Set the maximum number of lines to 1
              .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
            Spacer()
          }
        }
      }
      .padding(.horizontal,10)
      .accessibilityElement(children: .combine)
      .accessibilityLabel("""
                             \(item.name)
                             \(bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.species_id) ? "favorite": "not favorite") //changed id in species_id
                             \(speciesViewModel.findSpeciesByID(speciesID: item.species_id) ?? "noName")
                             \(item.scientific_name)
                            """
      )
      Spacer()



//xxx
      VStack {
        if let observations = observationsSpeciesViewModel.observationsSpecies?.results, observations.count > 0 {
          if showView { Text("observationsSpeciesViewModel").font(.customTiny) }
          HorizontalLine()
          ObservationListView(observations: observations, selectedSpeciesID: $selectedSpeciesID, entity: .species)
            .environmentObject(Settings()) // Pass environment object
        } else {
          ProgressView()
        }
      }

      .refreshable {
        print("refreshing...")
        fetchDataModel(offset: offset)
      }
      .onAppear() {
        if !hasAppeared {
          if settings.initialSpeciesLoad {
            fetchDataModel(offset: offset)
            settings.initialSpeciesLoad = false
          }
          hasAppeared = true // Prevent re-execution
        }
      }
    }
  }

  func fetchDataModel(offset: Int) {
    observationsSpeciesViewModel.fetchData(
      settings: settings,
      speciesId: item.species_id,
      limit: 100,
      offset: 0,
      completion: {
        isLoaded = true
        log.info("observationsSpeciesViewModel data loaded")
      }
    )
  }
}


//struct ObservationsSpeciesView_Previews: PreviewProvider {
//  static var previews: some View {
//    let testSpecies = Species(species: 62, name: "Unknown", scientific_name: "Scientific name", rarity: 1, native: true)
//    ObservationsSpeciesView(
//      item: testSpecies,
//      selectedSpeciesID: .constant(nil))
////      selectedObservation: .constant(nil))
////      selectedObservationSound: .constant(nil),
////      selectedObs: .constant(nil))
////      imageURLStr: .constant(""))
//    .environmentObject(ObservationsSpeciesViewModel())
//    .environmentObject(BookMarksViewModel())
//    .environmentObject(SpeciesViewModel())
//    .environmentObject(HTMLViewModel())
//    .environmentObject(Settings())
//  }
//}

