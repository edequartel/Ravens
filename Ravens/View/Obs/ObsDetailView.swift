//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/09/2024.
//

import SwiftUI
import RichText

struct ObsDetailView: View {
  var obs: Observation
  @Binding var selectedSpeciesID: Int?

  @State var imageURLStr: String?
  @State var selectedObservationSound: Observation?
  @State private var selectedObservationXX: Observation?

  @EnvironmentObject var userViewModel: UserViewModel
  @EnvironmentObject var keyChainViewModel: KeychainViewModel

  @State private var showPositionFullView = false

  var entity: EntityType

  var body: some View {
    ScrollView {

      VStack() {
        HStack {

          Button(action: {
            print("Information \(obs.speciesDetail.name) \(obs.speciesDetail.id)")
            selectedSpeciesID = obs.speciesDetail.id
          }) {
            Image(systemSymbol: SFInformation)
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
          //          (obs.userDetail?.id != (userViewModel.user?.id ?? 0))
          if !keyChainViewModel.token.isEmpty { //??
            BookmarkButtonView(speciesID: obs.species ?? 100)
            if (entity != .radius) && (obs.userDetail?.id != (userViewModel.user?.id ?? 0)) {
              ObserversButtonView(obs: obs)
            }

            AreaButtonView(obs: obs)
          }
        }
      }
      .padding([.leading, .trailing, .top])


      VStack(alignment: .leading, spacing: 20) {
        if showView {
          Text("ObsDetailView")
            .font(.customTiny)
            .padding(.bottom, 10)
        }
        
        // Header Section: Species Name & Rarity
        VStack(alignment: .leading, spacing: 10) {
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
        .padding()
        .islandBackground()
        .accessibilityElement(children: .combine)
//        .accessibility(value: Text("\(obs.speciesDetail.name) \(obs.speciesDetail.scientificName)"))


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

          if (entity != .radius) {
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


        NavigationLink(destination: PositonFullView(obs: obs)) {
          PositionOnMapView(obs: obs) // Replace with your view's content
            .frame(height: UIScreen.main.bounds.width / 2)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityHidden(true)

      }
      .padding()
    }

    .sheet(item: $selectedObservationSound) { item in
      PlayerControlsView(sounds: item.sounds ?? [])
        .presentationDetents([.fraction(0.25), .medium, .large])
        .presentationDragIndicator(.visible)
    }
    //
    .sheet(item: $selectedObservationXX) { item in
      SpeciesDetailsView(speciesID: item.speciesDetail.id)
    }

  }
}



struct ObsDetailView_Previews: PreviewProvider {
  static var previews: some View {
    let mockBookMarksViewModel = BookMarksViewModel(fileName: "bookmarks.json")
    ObsDetailView(
      obs: mockObservation,
      selectedSpeciesID: .constant(nil),
      entity: .radius
    )
    .environmentObject(mockBookMarksViewModel)
  }
}


