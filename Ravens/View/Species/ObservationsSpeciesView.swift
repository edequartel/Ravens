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

  @State private var hasAppeared = false

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0

  var item: Species

  @State private var offset = 0

  @State private var endOfListReached = false
  @State private var isLoaded = false

//  @Binding var selectedSpecies: Species?
  @Binding var selectedSpeciesID: Int?

//  @Binding var selectedObservation: Observation?
//  @Binding var selectedObservationSound: Observation?
//  @Binding var selectedObs: Observation?

//  @Binding var imageURLStr: String?


  var body: some View {
    VStack {
      if showView { Text("ObservationsSpeciesView").font(.customTiny) }
      HStack {
        //        Text("\(item.id)")
        //          .font(.footnote)
        //          .foregroundColor(.gray)

        Image(systemName: htmlViewModel.speciesScientificNameExists(item.scientific_name) ? "circle.hexagonpath.fill" : "circle.fill")
          .foregroundColor(RarityColor(value: item.rarity))

        Text("\(item.name)")// - \(item.id)")
          .bold()
          .lineLimit(1) // Set the maximum number of lines to 1
          .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
        Spacer()

        Button(action: {
          selectedSpeciesID = item.id
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
          ForEach(results, id: \.id) { obs in
            VStack {
              NavigationLink(destination: ObsDetailView(obs: obs)) {
                //              ObsSpeciesView(
                ObsView(
                  showSpecies: false,
                  selectedSpeciesID: $selectedSpeciesID,
                  obs: obs)
                .padding(8)
              }
              .accessibilityLabel("\(obs.species_detail.name) \(obs.date) \(obs.time ?? "")")
              Divider()
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
          }
        }
      }
      .listStyle(PlainListStyle())
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

