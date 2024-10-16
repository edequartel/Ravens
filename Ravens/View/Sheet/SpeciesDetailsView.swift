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

//}

//#Preview {
//    SpeciesDetailsView(item: Species())
//        .environmentObject(Settings())
//}
