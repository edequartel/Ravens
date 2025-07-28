//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/09/2024.
//

import SwiftUI
import RichText
import CoreLocation

struct ObsDetailView: View {
  var obs: Obs
  var entity: EntityType

  @State var imageURLStr: String?
  @State var selectedObservationSound: Obs?
  @State private var selectedObservation: Obs?

  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel

  @State private var showPositionFullView = false

  var body: some View {
    ScrollView {
      VStack {
        if showView { Text("ObsDetailView").font(.customTiny) }

        VStack(alignment: .leading, spacing: 20) {
          // Alternative when name isEmpty
          VStack(alignment: .leading, spacing: 10) {
            if obs.speciesDetail.name.isEmpty {
              HStack {
                Image(systemName: "circle.fill")
                  .foregroundColor(rarityColor(value: obs.rarity))
                Text("\(obs.speciesDetail.scientificName)")
                  .italic()
                  .lineLimit(1)
                  .truncationMode(.tail)
                Spacer()
              }
            } else {
              HStack {
                Image(systemName: "circle.fill")
                  .foregroundColor(rarityColor(value: obs.rarity))
                Text("\(obs.speciesDetail.name)")
                  .bold()
                  .lineLimit(1)
                  .truncationMode(.tail)
                Spacer()
              }
              HStack {
                Text("\(obs.speciesDetail.scientificName)")
                  .italic()
                  .lineLimit(1)
                  .truncationMode(.tail)
                Spacer()
              }
            }
          }
          .padding()
          .islandBackground()
          .accessibilityElement(children: .combine)

          // Scientific Name Section
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
              Text("\(obs.number) x")
                .footnoteGrayStyle()
            }
            HStack {
              Text("\(obs.locationDetail?.name ?? "")")
                .footnoteGrayStyle()
              Spacer()
            }

            if entity != .radius {
              HStack {
                Text("\(obs.userDetail?.name ?? "")")
                  .footnoteGrayStyle()
                Spacer()
              }
            }
          }
          .padding()
          .islandBackground()
          .accessibilityElement(children: .combine)

          HStack {
            NavigationLink(destination: SpeciesDetailsView(speciesID: obs.speciesDetail.id)) {
              Image(systemSymbol: .infoCircle)
                .uniformSize()
            }
            .accessibility(label: Text(informationSpecies))

            let url = URL(string: obs.permalink)!
            ShareLink(item: url) {
              Image(systemSymbol: SFShareLink)
                .uniformSize()
            }
            .accessibility(label: Text(shareThisObservation))

            Button(action: {
              if let url = URL(string: obs.permalink) {
                UIApplication.shared.open(url)
              }
            }) {
              Image(systemSymbol: SFObservation)
                .uniformSize()
            }
            .accessibility(label: Text(linkObservation))

            Spacer()

            if !keyChainViewModel.token.isEmpty {
              BookmarkButtonView(speciesID: obs.species ?? 100)
              if (entity != .radius) && (obs.userDetail?.id != (userViewModel.user?.id ?? 0)) {
                ObserversObsButtonView(obs: obs)
              }

              AreaButtonView(obs: obs)
            }
          }
        }

        // Photos Section
        if let photos = obs.photos, photos.count > 0 {
          PhotoGridView(photos: photos)
            .islandBackground()
            .accessibilityHidden(true)
        }

        // Sounds Section
        if let sounds = obs.sounds, sounds.count > 0 {
          Button(action: {
            selectedObservationSound = obs
          }) {
            HStack {
              Image(systemName: "play.fill")
              Text(play)
              Spacer()
            }
          }
          .padding()
          .islandBackground()
          .accessibilityLabel(play)
        }

        NotesView(obs: obs)
          .padding()
          .islandBackground()
          .accessibility(label: Text(notesAboutObservation))

        NavigationLink(destination: FullMapView(obs: obs)) {
          PositionOnMapView(obs: obs)
            .frame(height: UIScreen.main.bounds.width / 2)
            .cornerRadius(8)
            .contentShape(Rectangle())
            .accessibilityHidden(true)
        }
        .buttonStyle(PlainButtonStyle()) // Removes tap effects
      }
      .padding()
    }

    .sheet(item: $selectedObservationSound) { item in
      PlayerControlsView(sounds: item.sounds ?? [])
        .presentationDetents([.fraction(0.25), .medium, .large])
        .presentationDragIndicator(.visible)
    }
    //
    .sheet(item: $selectedObservation) { item in
      SpeciesDetailsView(speciesID: item.speciesDetail.id)
    }
  }

  // Fullscreen destination map view
  struct FullMapView: View {
    let obs: Obs

    var body: some View {
      PositionOnMapView(obs: obs, allowsHitTesting: true)
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ObsDetailView_Previews: PreviewProvider {
  static var previews: some View {
    let mockBookMarksViewModel = BookMarksViewModel(fileName: "bookmarks.json")
    ObsDetailView(
      obs: mockObservation,
      entity: .radius
    )
    .environmentObject(mockBookMarksViewModel)
  }
}
