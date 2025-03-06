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
//  @EnvironmentObject var notificationsManager: NotificationsManager
  @EnvironmentObject var settings: Settings

  var speciesID: Int
  @State private var imageURL: String = ""

  var body: some View {
      ScrollView {
        if showView { Text("SpeciesDetailsView").font(.customTiny) }
        VStack(alignment: .leading, spacing: 16) {
          // Species Details Header
          if let species = viewSpeciesDetailsDModel.speciesDetails {
            HStack {
              Link(destination: URL(string: species.permalink)!) {
                Label("More Info", systemImage: "arrow.up.right.square")
                  .font(.headline)
                  .padding()
                  .foregroundColor(.blue)
                  .islandBackground() // Assuming this is a custom modifier
              }
              Spacer()
              Button(action: {
                openWikipediaPage(for: species.scientificName)
              }) {
                Label("Wikipedia", systemImage: "book.fill")
                  .font(.headline)
                  .padding()
                  .foregroundColor(.blue)
                  .islandBackground() // Assuming this is a custom modifier
              }
            }
            VStack(alignment: .leading, spacing: 8) {
              Text(species.name)
                .font(.title)
                .bold()

              Text(species.scientificName)
                .italic()
                .foregroundColor(.gray)

              HStack {
                Text("\(species.groupName) - ")
                //                                Spacer()
                Text("\(species.status) - ")
                //                                Spacer()
                Text("\(species.rarity)")
                Spacer()
              }
              .font(.footnote)
              .foregroundColor(.gray)
            }
            .padding()
            .islandBackground()
            .accessibilityElement(children: .combine)

            // Image Display
            if !imageURL.isEmpty {
              KFImage(URL(string: imageURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .islandBackground()
                .accessibility(hidden: true)
            }

            //share the image
            if !imageURL.isEmpty {
                URLShareButtonView(urlShare: imageURL)
                .accessibilityLabel(sharePictureLink)
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
//    }
    .presentationDragIndicator(.visible)
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

//}

#Preview {
  SpeciesDetailsView(speciesID: 58)
        .environmentObject(Settings())
}





