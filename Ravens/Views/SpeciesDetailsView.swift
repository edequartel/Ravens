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
import AlamofireImage

struct SpeciesDetailsView: View {
    let log = SwiftyBeaver.self
    
    @StateObject var viewSDModel = SpeciesDetailsViewModel(settings: Settings())
    
    @EnvironmentObject var observationsYearViewModel: ObservationsYearViewModel
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int
    
    var body: some View {
        Form{
            VStack(alignment: .leading) {
                if let species = viewSDModel.speciesDetails {
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
                    AFImageView(media: species.photo)
                        .frame(maxWidth: .infinity, maxHeight: 400)
                    Divider()
                        .frame(height: 20)
                        .opacity(0)
                    YearView(speciesId: speciesID)
                    Divider()
                        .frame(height: 20)
                        .opacity(0)
                    RichText(html: species.info_text)
                    Link("More at waarneming.nl", destination: URL(string: species.permalink)!)
                } else {
                    ProgressView()
                }
                
            }
        }
        .onAppear {
            log.info("Calling SpeciesDetailsView FetchData \(speciesID)")
            
            viewSDModel.fetchData(for: speciesID)
        }
    }
}

#Preview {
    SpeciesDetailsView(speciesID: 245)
        .environmentObject(Settings())
}
