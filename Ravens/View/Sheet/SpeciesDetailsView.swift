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
  @State private var wikipediaPage: WikipediaPage?
  @State private var isLoadingWikipedia = false

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

            WikipediaSummaryCard(
              page: wikipediaPage,
              isLoading: isLoadingWikipedia,
              onOpen: {
                openWikipediaPage(for: species.scientificName)
              }
            )

            HStack {
//              Link(destination: URL(string: species.permalink)!) {
//                SVGImage(svg: "waarneming")
//              }

  //              Button(action: {
  //                openWikipediaPage(for: species.scientificName)
  //              }) {
  //                SVGImage(svg: "wikipedia")
  //              }

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
      .toolbar {
        if let species = viewSpeciesDetailsModel.speciesDetails {
          if [1, 2, 3, 14].contains(species.group) {
            ToolbarItem(placement: .navigationBarTrailing) {
              NavigationLink(destination: BirdListView(scientificName: species.scientificName)) {
                Image(systemName: "waveform")
                  .uniformSize()
              }
              .accessibility(label: Text(audioListView))
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            let localizedIntro = String(localized: "aiChat")
            let message = "\(localizedIntro) \(species.scientificName)"

            ShareLink(item: message) {
              Image(systemName: "brain.head.profile")
                .uniformSize()
            }
          }
        }
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
          if let species = viewSpeciesDetailsModel.speciesDetails {
            fetchWikipediaSummary(for: species.scientificName)
          }
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

  func fetchWikipediaSummary(for searchTerm: String) {
    wikipediaPage = nil
    isLoadingWikipedia = true

    let formattedTerm = searchTerm
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: " ", with: "_")

    guard
      let encodedTerm = formattedTerm.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
      let url = URL(string: "https://\(settings.selectedLanguage).wikipedia.org/api/rest_v1/page/summary/\(encodedTerm)")
    else {
      isLoadingWikipedia = false
      return
    }

    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    URLSession.shared.dataTask(with: request) { data, _, _ in
      guard let data = data else {
        DispatchQueue.main.async {
          isLoadingWikipedia = false
        }
        return
      }

      let page = try? JSONDecoder().decode(WikipediaPage.self, from: data)
      DispatchQueue.main.async {
        wikipediaPage = page
        isLoadingWikipedia = false
      }
    }
    .resume()
  }
}

struct WikipediaSummaryCard: View {
  let page: WikipediaPage?
  let isLoading: Bool
  let onOpen: () -> Void

  var body: some View {
    Group {
      if isLoading {
        HStack(spacing: 10) {
          ProgressView()
          Text("Wikipedia")
            .font(.headline)
          Spacer()
        }
        .padding()
        .islandBackground()
      } else if let page, !page.extract.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .center, spacing: 8) {
            SVGImage(svg: "wikipedia")
            Text(page.title)
              .font(.headline)
              .lineLimit(2)
            Spacer()
            Button(action: onOpen) {
              Image(systemName: "arrow.up.forward.app")
                .uniformSize()
            }
            .accessibilityLabel("Open Wikipedia")
          }

          Text(page.extract)
            .font(.body)
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .islandBackground()
      }
    }
  }
}

#Preview {
  SpeciesDetailsView(speciesID: 58)
        .environmentObject(Settings())
}
