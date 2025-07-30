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
import SVGView

struct SpeciesDetailsView: View {
  let log = SwiftyBeaver.self
  @EnvironmentObject var viewSpeciesDetailsModel: SpeciesDetailsViewModel

  @StateObject private var observationsSpecies = ObservationsViewModel()

  @State private var isSharing = false

  @EnvironmentObject var settings: Settings

  var speciesID: Int

  @State private var imageURL: String = ""
  @State private var showSpeciesXC: Species?

  var item: Species?
  var selectedSpeciesID: Int?

  var body: some View {
    NavigationStack {
      ScrollView {
        if showView { Text("SpeciesDetailsView").font(.customTiny) }
        VStack { 
          // Species Details Header
          if let species = viewSpeciesDetailsModel.speciesDetails {
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
              }
              .buttonStyle(.plain)
              .accessibilityLabel("Share image")
            }

            HStack {
              Link(destination: URL(string: species.permalink)!) {
                SVGImage(svg: "waarneming")
              }

              if [1, 2, 3, 14].contains(species.group) {
                NavigationLink(destination: BirdListView(scientificName: species.scientificName)) {
                  SVGImage(svg: "waveform")
//                  Image(systemSymbol: .waveform)
//                    .uniformSize()

                }
                .accessibility(label: Text(audioListView))
              }

              Button(action: {
                openWikipediaPage(for: species.scientificName)
              }) {
                SVGImage(svg: "wikipedia")
              }

              ShareLink(item: "Provide the etymology of the following species name in plain text, along with an optional fun fact. " + species.scientificName) {
                SVGImage(svg: "artificialintel")
//                artificialintel
//                Image(systemSymbol: .sharedWithYou)
//                  .uniformSize()
              }
              Spacer()
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
      viewSpeciesDetailsModel.fetchData(
        settings: settings,
        for: speciesID,
        onCompletion: {
          imageURL = viewSpeciesDetailsModel.speciesDetails?.photo ?? ""
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

#Preview {
  SpeciesDetailsView(speciesID: 58)
        .environmentObject(Settings())
}
