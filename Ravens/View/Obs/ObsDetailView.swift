//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/09/2024.
//

import SwiftUI

struct PlayButtonView: View {
    var body: some View {
        Button(action: {
            // Add your play audio action here
            print("Play button pressed")
        }) {
            Image(systemName: "play.fill") // SF Symbol for play button
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40) // Icon size
                .foregroundColor(.white) // Icon color
                .padding(20) // Padding around the icon
                .background(
                    Circle()
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                ) // Circular gradient background with shadow
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
    }
}


struct ObsDetailView: View {
    var obs: Observation
    @Binding var selectedSpeciesID: Int?

    @State var imageURLStr: String?
    @State var selectedObservationSound: Observation?
    @State private var selectedObservationXX: Observation?

    var body: some View {
      ScrollView {
        VStack(alignment: .leading) {
          if showView { Text("ObsDetailView").font(.customTiny) }

          // Header Section: Species Name & Rarity
          VStack() {
            HStack {
              Image(systemName: "circle.fill")
                .foregroundColor(RarityColor(value: obs.rarity))
              Text("\(obs.species_detail.name)")
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
              Spacer()
            }
            HStack {
              Text("\(obs.species_detail.scientific_name)")
                .italic()
                .lineLimit(1)
                .truncationMode(.tail)
              Spacer()
            }

            HStack {
              Button(action: {
                print("Information \(obs.species_detail.name) \(obs.species_detail.id)")
                selectedSpeciesID = obs.species_detail.id
              }) {
                Image(systemName: SFInformation)
              }

              BookmarkButtonView(speciesID: obs.species_detail.id)

              let url = URL(string: obs.permalink)!
              ShareLink(
                item: url
              )
              {
                Image(systemName: SFShareLink)
              }
              .accessibility(label: Text("Share observation"))

              Button(action: {
                if let url = URL(string: obs.permalink) {
                  UIApplication.shared.open(url)
                }

              }) {
                Image(systemName: SFObservation)
              }
              .accessibility(label: Text("Link to waarneming observation"))


              Spacer()
            }
            .padding(.vertical)
          }

          // Photos Section
          if let photos = obs.photos, photos.count > 0 {
            PhotoGridView(photos: photos, imageURLStr: $imageURLStr)
          }

          // Sounds Section
          if let sounds = obs.sounds, sounds.count > 0 {
            Button(action: {
              selectedObservationSound = obs
            }) {
              HStack {
                Image(systemName: "play.fill")
                Text("Play Sounds")
                Spacer()
              }
              .padding()
              .background(Color(UIColor.systemGray6))
              .cornerRadius(8)
            }
          }

          // Scientific Name Section
          VStack(alignment: .leading) {
            DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
            Text("\(obs.number) x")
            HStack {
              Text("\(obs.user_detail?.name ?? "noName")")
              Spacer()
              Image(systemName: SFObserverFill)
                .foregroundColor(.black)
            }
          }
          .footnoteGrayStyle()

          // Map View Section
          PositionOnMapView(lat: obs.point.coordinates[1], long: obs.point.coordinates[0])
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 2)
            .cornerRadius(8)

          // Notes Section
          NotesView(obs: obs)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)

//          Spacer()
        }

      }
      .padding(.leading, 120)
      .padding(.trailing, 120)


      .sheet(item: $selectedObservationSound) { item in
        PlayerControlsView(sounds: item.sounds ?? [])
          .presentationDetents([.fraction(0.25), .medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(item: $selectedObservationXX) { item in
        SpeciesDetailsView(speciesID: item.species_detail.id)
      }



    }

}

struct ObsDetailView_Previews: PreviewProvider {
    static var previews: some View {
      let mockBookMarksViewModel = BookMarksViewModel()
      ObsDetailView(
        obs: mockObservation,
        selectedSpeciesID: .constant(nil)
      )
      .environmentObject(mockBookMarksViewModel)
    }
}


