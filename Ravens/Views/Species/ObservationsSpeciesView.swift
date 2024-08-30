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
  @EnvironmentObject var htmlViewModel: HTMLViewModel
  @EnvironmentObject var settings: Settings

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0

  var item: Species

  @State private var offset = 0

  @State private var endOfListReached = false
  @State private var isLoaded = false

  @Binding var selectedSpecies: Species?
  @Binding var selectedObservationSound: Observation?
  @Binding var imageURLStr: String?


  var body: some View {
    VStack {
      HStack {
        Text("\(item.id)")
          .font(.footnote)
          .foregroundColor(.gray)

        Image(systemName: htmlViewModel.speciesScientificNameExists(item.scientific_name) ? "circle.hexagonpath.fill" : "circle.fill")
          .foregroundColor(RarityColor(value: item.rarity))

        Text("\(item.name)")// - \(item.id)")
          .bold()
          .lineLimit(1) // Set the maximum number of lines to 1
          .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
        Spacer()

        Button(action: {
          selectedSpecies = item
        }  ) { Image(systemName: "info.circle")
        }

        Button(action: {
          if bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) {
            print("bookmarks remove")
            bookMarksViewModel.removeRecord(speciesID: item.id)
          } else {
            bookMarksViewModel.appendRecord(speciesID: item.id)
            print("bookmarks append")
          }

        } ) {
          Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) ? SFSpeciesFill : SFSpecies)
            .foregroundColor(.black)
        }
      }

      VStack {
        HStack {
          Text(speciesViewModel.findSpeciesByID(speciesID: item.id) ?? "noName")
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
//      Spacer()
    }

    .padding(.horizontal,10)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("""
                             \(item.name)
                             \(bookMarksViewModel.isSpeciesIDInRecords(speciesID: item.id) ? "favorite": "not favorite")
                             \(speciesViewModel.findSpeciesByID(speciesID: item.id) ?? "noName")
                             \(item.scientific_name)
                            """
    )

    HorizontalLine()

    VStack {
      List {
        if let results = observationsSpeciesViewModel.observationsSpecies?.results {
          let sortedResults = results.sorted(by: { ($1.date, $0.time ?? "" ) < ($0.date, $1.time ?? "") })
          ForEach(sortedResults.indices, id: \.self) { index in
            let obs = sortedResults[index]
            ObsSpeciesView(
              obs: obs,
              imageURLStr: $imageURLStr
            )
            .onTapGesture() {
              if let sounds = obs.sounds, !sounds.isEmpty {
                selectedObservationSound = obs
              }
            }
          }
        }
      }
      .listStyle(PlainListStyle())
      .refreshable {
        print("refreshing...")
        fetchDataModel(offset: offset)
      }


      .onAppear() {
        if settings.initialSpeciesLoad {
          fetchDataModel(offset: offset)
          settings.initialSpeciesLoad = false
        }

      }
      //            Text("last item in list")
      //            Spacer()
    } //vstack


    //deze button voor later gebruiken als we door de vele observaties willen gaan
    //        Button(action: {
    //            offset = offset + 100
    //            fetchDataModel(offset: offset)
    //        }) {
    //            Text("Next")
    //        }
  }

  func fetchDataModel(offset: Int) {
    observationsSpeciesViewModel.fetchData(
      settings: settings,
      speciesId: item.id,
      limit: 100,
      offset: 0,
      completion: {
        isLoaded = true
        log.info("observationsSpeciesViewModel data loaded")
      }
    )
  }
}


struct ObservationsSpeciesView_Previews: PreviewProvider {
  static var previews: some View {
    let testSpecies = Species(species: 62, name: "Unknown", scientific_name: "Scientific name", rarity: 1, native: true)
    ObservationsSpeciesView(
      item: testSpecies,
      selectedSpecies: .constant(nil),
      selectedObservationSound: .constant(nil),
      imageURLStr: .constant(""))
      .environmentObject(ObservationsSpeciesViewModel())
      .environmentObject(BookMarksViewModel())
      .environmentObject(SpeciesViewModel())
      .environmentObject(HTMLViewModel())
      .environmentObject(Settings())
  }
}

