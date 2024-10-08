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
    @EnvironmentObject var observationsYearViewModel: ObservationsYearViewModel
    @EnvironmentObject var settings: Settings

    var speciesID: Int
    @State private var imageURL: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Species Details Header
                    if let species = viewSpeciesDetailsDModel.speciesDetails {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(species.name)
                                .font(.title)
                                .bold()

                            Text(species.scientific_name)
                                .italic()
                                .foregroundColor(.gray)

                            HStack {
                                Text("\(species.group_name)")
                                Spacer()
                                Text("\(species.status)")
                                Spacer()
                                Text("\(species.rarity)")
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                        .padding()
                        .islandBackground()

                        // Image Display
                        if !imageURL.isEmpty {
                            KFImage(URL(string: imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .islandBackground()
                        }

                        // Information Text
                      if species.info_text != "" {
                        RichText(html: species.info_text)
                          .padding()
                          .islandBackground()
                      }

                        // More Information Link
                      HStack {
                        Spacer()
                        Link("More at waarneming.nl", destination: URL(string: species.permalink)!)
                          .font(.headline)
                          .padding()
                          .islandBackground()
                        Spacer()
                      }

                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
//            .navigationBarTitle("Species Details", displayMode: .inline)
        }
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
}

//struct SpeciesDetailsView: View {
//    let log = SwiftyBeaver.self
//    @EnvironmentObject var viewSpeciesDetailsDModel: SpeciesDetailsViewModel
//    @EnvironmentObject var observationsYearViewModel: ObservationsYearViewModel
//    @EnvironmentObject var settings: Settings
//
//    var speciesID: Int
//    @State private var imageURL: String = ""
//
//    var body: some View {
//        NavigationView {
//            Form{
//                VStack(alignment: .leading) {
//                  if showView { Text("SpeciesDetailsView").font(.customTiny) }
//                  
//                    if let species = viewSpeciesDetailsDModel.speciesDetails {
//                        VStack(alignment: .leading) {
//                            Text(species.name)
//                                .bold()
//                                .font(.title)
//                            Text(species.scientific_name)
//                                .italic()
//                                .foregroundColor(.gray)
//                                .font(.footnote)
//                          HStack {
//                            Text("\(species.group_name)")
////                            Spacer()
//                            Text("\(species.status)")
////                            Spacer()
//                            Text("\(species.rarity)")
//                            Spacer()
//                          }
//                          .foregroundColor(.gray)
//                          .font(.footnote)
//                        }
//                        Divider()
//                            .frame(height: 20)
//
//                        if !imageURL.isEmpty {
//                            KFImage(URL(string: imageURL))
//                                .resizable()
//                                .aspectRatio(nil, contentMode: .fit)
//                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        }
//                        if !imageURL.isEmpty {
//                            Divider()
//                                .frame(height: 20)
//                                .opacity(0)
//                        }
//
////                        YearView(speciesId: species.id) //?? deze goed controleren
////                        //
////                        Divider()
////                            .frame(height: 20)
////                            .opacity(0)
//
//                        RichText(html: species.info_text)
//                        Link("More at waarneming.nl", destination: URL(string: species.permalink)!)
//                    } else {
//                        ProgressView()
//                    }
//
//                }
//
//            }
//
//        }
//        .presentationDragIndicator(.visible)
//        .onAppear {
//            log.info("Calling SpeciesDetailsView FetchData \(speciesID)")
//            viewSpeciesDetailsDModel.fetchData(
//                settings: settings,
//                for: speciesID,
//                onCompletion: {
//                    log.info("SpeciesDetailsView onAppear \(viewSpeciesDetailsDModel.speciesDetails?.photo ?? "")")
//                    imageURL = viewSpeciesDetailsDModel.speciesDetails?.photo ?? ""
//                } )
//        }
//    }
//}

//struct SpeciesDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Initialize the dummy objects here
//        let speciesDetailsViewModel = SpeciesDetailsViewModel()
//        let observationsYearViewModel = ObservationsYearViewModel()
//        let settings = Settings()
//
//        // Provide the dummy objects to the SpeciesDetailsView
//        SpeciesDetailsView(speciesID: 0)
//            .environmentObject(speciesDetailsViewModel)
//            .environmentObject(observationsYearViewModel)
//            .environmentObject(settings)
//    }
//}

//#Preview {
//    SpeciesDetailsView(item: Species())
//        .environmentObject(Settings())
//}
