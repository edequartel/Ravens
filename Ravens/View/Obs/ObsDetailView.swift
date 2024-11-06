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

    var body: some View {
        ScrollView {
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
              }
              .padding()
              .islandBackground()

              VStack {
                    HStack {

                      BookmarkButtonView(obs: obs, colorOn: false)
                      ObserversButtonView(obs: obs, colorOn: false)
                      AreaButtonView(obs: obs, colorOn: false)

                      Spacer()

                      Button(action: {
                          print("Information \(obs.species_detail.name) \(obs.species_detail.id)")
                          selectedSpeciesID = obs.species_detail.id
                      }) {
                          Image(systemSymbol: SFInformation)
                          .uniformSize()
                      }

                        let url = URL(string: obs.permalink)!
                        ShareLink(item: url) {
                            Image(systemSymbol: SFShareLink)
                            .uniformSize()
                        }
                        .accessibility(label: Text("Share observation"))

                        Button(action: {
                            if let url = URL(string: obs.permalink) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemSymbol: SFObservation)
                            .uniformSize()
                        }
                        .accessibility(label: Text("Link to waarneming observation"))

//                        Spacer()
                    }
                }
                .padding()
                .islandBackground()



                // Photos Section
                if let photos = obs.photos, photos.count > 0 {
                    PhotoGridView(photos: photos, imageURLStr: $imageURLStr)
                        .padding()
                        .islandBackground()
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
                        .islandBackground()
                    }
                }

                // Scientific Name Section
              VStack(alignment: .leading, spacing: 10) {

                HStack {
                  DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
                  Text("\(obs.number) x")
                    .footnoteGrayStyle()
                }

                HStack {
                  Text("\(obs.user_detail?.name ?? "noName")")
                    .footnoteGrayStyle()
                  Spacer()
//                  Image(systemSymbol: SFObserverFill)
//                    .foregroundColor(.black)
                }
              }
              .padding()
              .islandBackground()

              NotesView(obs: obs)
                .padding()
                .islandBackground()

              NavigationLink(destination: PositonFullView(obs: obs)) {
                          VStack {
                              // Content of the PositionOnMapView that acts as the clickable area
                            PositionOnMapView(obs: obs) // Replace with your view's content
                                  .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width / 2)
                                  .padding(6)
                                  .islandBackground()
                          }
                          .contentShape(Rectangle()) // Ensures the whole view is tappable
                      }

            }
            .padding()
        }
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


//struct ObsDetailView: View {
//    var obs: Observation
//    @Binding var selectedSpeciesID: Int?
//
//    @State var imageURLStr: String?
//    @State var selectedObservationSound: Observation?
//    @State private var selectedObservationXX: Observation?
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                if showView {
//                    Text("ObsDetailView")
//                        .font(.customTiny)
//                        .padding(.bottom, 10)
//                }
//
//                // Header Section: Species Name & Rarity
//              VStack(alignment: .leading, spacing: 10) {
//                HStack {
//                  Image(systemName: "circle.fill")
//                    .foregroundColor(rarityColor(value: obs.rarity))
//                  Text("\(obs.species_detail.name)")
//                    .bold()
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                  Spacer()
//                }
//                HStack {
//                  Text("\(obs.species_detail.scientific_name)")
//                    .italic()
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                  Spacer()
//                }
//              }
//              .padding()
//              .islandBackground()
//
//              VStack {
//                    HStack {
//
//
//                      BookmarkButtonView(obs: obs)
//
//                      ObserversButtonView(obs: obs)
//
//                      AreaButtonView(obs: obs)
//
//
//                      Spacer()
//
//                      Button(action: {
//                          print("Information \(obs.species_detail.name) \(obs.species_detail.id)")
//                          selectedSpeciesID = obs.species_detail.id
//                      }) {
//                          Image(systemSymbol: SFInformation)
//                          .uniformSize()
//                      }
//
//                        let url = URL(string: obs.permalink)!
//                        ShareLink(item: url) {
//                            Image(systemSymbol: SFShareLink)
//                            .uniformSize()
//                        }
//                        .accessibility(label: Text("Share observation"))
//
//                        Button(action: {
//                            if let url = URL(string: obs.permalink) {
//                                UIApplication.shared.open(url)
//                            }
//                        }) {
//                            Image(systemSymbol: SFObservation)
//                            .uniformSize()
//                        }
//                        .accessibility(label: Text("Link to waarneming observation"))
//
////                        Spacer()
//                    }
//                }
//                .padding()
//                .islandBackground()
//
//
//
//                // Photos Section
//                if let photos = obs.photos, photos.count > 0 {
//                    PhotoGridView(photos: photos, imageURLStr: $imageURLStr)
//                        .padding()
//                        .islandBackground()
//                }
//
//                // Sounds Section
//                if let sounds = obs.sounds, sounds.count > 0 {
//                    Button(action: {
//                        selectedObservationSound = obs
//                    }) {
//                        HStack {
//                            Image(systemName: "play.fill")
//                            Text("Play Sounds")
//                            Spacer()
//                        }
//                        .padding()
//                        .islandBackground()
//                    }
//                }
//
//                // Scientific Name Section
//              VStack(alignment: .leading, spacing: 10) {
//
//                HStack {
//                  DateConversionView(dateString: obs.date, timeString: obs.time ?? "")
//                  Text("\(obs.number) x")
//                    .footnoteGrayStyle()
//                }
//
//                HStack {
//                  Text("\(obs.user_detail?.name ?? "noName")")
//                    .footnoteGrayStyle()
//                  Spacer()
////                  Image(systemSymbol: SFObserverFill)
////                    .foregroundColor(.black)
//                }
//              }
//              .padding()
//              .islandBackground()
//
//              NotesView(obs: obs)
//                .padding()
//                .islandBackground()
//
//              NavigationLink(destination: PositonFullView(obs: obs)) {
//                          VStack {
//                              // Content of the PositionOnMapView that acts as the clickable area
//                            PositionOnMapView(obs: obs) // Replace with your view's content
//                                  .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width / 2)
//                                  .padding(6)
//                                  .islandBackground()
//                          }
//                          .contentShape(Rectangle()) // Ensures the whole view is tappable
//                      }
//
//            }
//            .padding(.horizontal, 20)
//        }
//        .sheet(item: $selectedObservationSound) { item in
//            PlayerControlsView(sounds: item.sounds ?? [])
//                .presentationDetents([.fraction(0.25), .medium, .large])
//                .presentationDragIndicator(.visible)
//        }
//        .sheet(item: $selectedObservationXX) { item in
//            SpeciesDetailsView(speciesID: item.species_detail.id)
//        }
//    }
//}
