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

struct BookmarkButtonView: View {
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
    var speciesID: Int

    var body: some View {
        Button(action: {
            if bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) {
                bookMarksViewModel.removeRecord(speciesID: speciesID)
            } else {
                bookMarksViewModel.appendRecord(speciesID: speciesID)
            }
        }) {
            Image(systemName: bookMarksViewModel.isSpeciesIDInRecords(speciesID: speciesID) ? SFSpeciesFill : SFSpecies)
        }
//        .tint(.obsSpecies)
    }
}

struct ObsDetailView: View {
    var obs: Observation

    @Binding var selectedSpeciesID: Int?

    @State var imageURLStr: String?
    @State var selectedObservationSound: Observation?
    @State private var selectedObservationXX: Observation?

    var body: some View {
//        ZStack {
            // Background color (light gray)
//          Color(UIColor.systemBrown)
//                .edgesIgnoringSafeArea(.all) // Extends the background to the edges of the screen

            ScrollView {
                VStack(spacing: 16) {
                    // Header Section: Species Name & Rarity
                    HStack {

                      Button(action: {
                        print("Information \(obs.species_detail.name) \(obs.species_detail.id)")
                        selectedSpeciesID = obs.species_detail.id
                        //    }
                      }) {
                        Image(systemName: SFInformation)
                      }
//                      .tint(.obsInformation)

                      BookmarkButtonView(speciesID: obs.species_detail.id)


                        Image(systemName: "circle.fill")
                            .foregroundColor(RarityColor(value: obs.rarity))
                        Text("\(obs.species_detail.name)")
                            .font(.title)
                            .bold()
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Photos Section
                    if let photos = obs.photos, photos.count > 0 {
                        PhotoGridView(photos: photos, imageURLStr: $imageURLStr)
                            .padding(.horizontal)
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
                        .padding(.horizontal)
                    }

                    // Scientific Name Section
                    HStack {
                        Text("\(obs.species_detail.scientific_name)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .italic()
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Date and Count Section
                    HStack {
                        DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
                        Text("\(obs.number) x")
                        .footnoteGrayStyle()
                        Spacer()
                    }

                    .padding(.horizontal)

                    // User Info Section
                    HStack {
                        Text("\(obs.user_detail?.name ?? "noName")")
                            .footnoteGrayStyle()
                        Spacer()
                        Image(systemName: SFObserverFill)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    // Map View Section
                    PositionOnMapView(lat: obs.point.coordinates[1], long: obs.point.coordinates[0])
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.horizontal)

                    // Notes Section
                    NotesView(obs: obs)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical)
            }
//        }
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




//#Preview {
//  ObsView(obs: .constant(nil))
//}
