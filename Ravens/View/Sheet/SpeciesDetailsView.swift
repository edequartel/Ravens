//
//  SpeciesDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import RichText
import SwiftyBeaver
import Alamofire
import Kingfisher

struct SpeciesDetailsView: View {
  let log = SwiftyBeaver.self
  @EnvironmentObject var viewSpeciesDetailsDModel: SpeciesDetailsViewModel
  @StateObject private var observationsSpecies = ObservationsViewModel()
//  @ObservedObject var observationsSpecies: ObservationsViewModel
//  @EnvironmentObject var observationsSpecies: ObservationsViewModel //??

  @State private var isSharing = false

  @EnvironmentObject var settings: Settings

  var speciesID: Int
  @State private var imageURL: String = ""
  @State private var showSpeciesXC: Species?

//  private var item: Species
//  @State var selectedSpeciesID: Int?

  var body: some View {
    NavigationStack {
      ScrollView {
        if showView { Text("SpeciesDetailsView").font(.customTiny) }
        VStack{ //}(alignment: .leading, spacing: 16) {
          // Species Details Header
          if let species = viewSpeciesDetailsDModel.speciesDetails {
            VStack(alignment: .leading, spacing: 8) {
              Text(species.name)
                .font(.title)
                .bold()

              Text(species.scientificName)
                .italic()
                .foregroundColor(.gray)

              HStack {
                Text("\(species.groupName) - \(species.status) - \(species.rarity)")
                Spacer()
              }
              .font(.footnote)
              .foregroundColor(.gray)
            }
            .padding()
            .islandBackground()
            .accessibilityElement(children: .combine)

            // Image Display
            if let url = URL(string: imageURL), !imageURL.isEmpty {
                    ShareLink(item: url) {
                      KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .islandBackground()
                    }
                    .accessibilityLabel("Share image")
                  }


            HStack {
//              Spacer()

//                            NavigationLink(destination: ObservationsSpeciesView(
//                              observationsSpecies: observationsSpecies,
//                              item: item,
//                              selectedSpeciesID: $selectedSpeciesID,
//                              timePeriod: $settings.timePeriodSpecies
//                            )) {
//                              Text("obs")
//                            }

              Link(destination: URL(string: species.permalink)!) {
                Image(systemSymbol: .binocularsFill)
                  .uniformSize()
              }

              if [1, 2, 3, 14].contains(species.group) {
                NavigationLink(destination: BirdListView(scientificName: species.scientificName)) {
                  Image(systemSymbol: .waveform)
                    .uniformSize()
                }
                .accessibility(label: Text(audioListView))
              }

              Button(action: {
                openWikipediaPage(for: species.scientificName)
              }) {
                Image(systemName: "book.fill")
                  .uniformSize()
              }
            }

            // Information Text
            if species.infoText != "" {
              RichText(html: species.infoText)
                .padding()
                .islandBackground()
            }

          } else {
            ProgressView()
          }
        }
        .padding()
      }
    }
    //    }
//    .presentationDragIndicator(.visible)
    .onAppear {
      log.info("Calling SpeciesDetailsView FetchData \(speciesID)")
      viewSpeciesDetailsDModel.fetchData(
        settings: settings,
        for: speciesID,
        onCompletion: {
          imageURL = viewSpeciesDetailsDModel.speciesDetails?.photo ?? ""
        }
      )
    }
  }

  func openWikipediaPage(for searchTerm: String) {
    let formattedTerm = searchTerm.lowercased().replacingOccurrences(of: " ", with: "_")
    if let url = URL(string: "https://\(settings.selectedLanguage).m.wikipedia.org/wiki/\(formattedTerm)") {
      UIApplication.shared.open(url)
    }
  }
}

//#Preview {
//  SpeciesDetailsView(speciesID: 58)
//        .environmentObject(Settings())
//}
