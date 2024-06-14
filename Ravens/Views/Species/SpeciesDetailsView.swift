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
            Form{
                VStack(alignment: .leading) {
                    if let species = viewSpeciesDetailsDModel.speciesDetails {
                        VStack(alignment: .leading) {
                            Text(species.name)
                                .bold()
                                .font(.title)
                            Text(species.scientific_name)
                                .italic()
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        Divider()
                            .frame(height: 20)
                        
                        if !imageURL.isEmpty {
                            KFImage(URL(string: imageURL))
                                .resizable()
                                .aspectRatio(nil, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        if !imageURL.isEmpty {
                            Divider()
                                .frame(height: 20)
                                .opacity(0)
                        }
                        
                        //                                YearView(speciesId: species.id)
                        //
                        //                                Divider()
                        //                                    .frame(height: 20)
                        //                                    .opacity(0)
                        
                        RichText(html: species.info_text)
                        Link("More at waarneming.nl", destination: URL(string: species.permalink)!)
                    } else {
                        ProgressView()
                    }
                    
                }
            }
        }
        .onAppear {
            log.error("Calling SpeciesDetailsView FetchData \(speciesID)")
            viewSpeciesDetailsDModel.fetchData(
                settings: settings,
                for: speciesID,
                onCompletion: {
                    print("SpeciesDetailsView onAppear \(viewSpeciesDetailsDModel.speciesDetails?.photo ?? "")")
                    imageURL = viewSpeciesDetailsDModel.speciesDetails?.photo ?? ""
                } )
        }
    }
}


//#Preview {
//    SpeciesDetailsView(item: Species())
//        .environmentObject(Settings())
//}
