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
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int // Add speciesID as a property

    var body: some View {
        Form{
            VStack {
                if let species = viewSDModel.speciesDetails {
                    AFImageView(media: species.photo)

                    Divider()
                    
                    YearView(monthlyViews: [12, 15, 8, 20, 50, 180, 250, 140, 60, 12, 20, 18])
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(species.name)
                                .bold()
                            Spacer()
                            Text(species.scientific_name)
                                .italic()
                        }
                        Divider()
                        RichText(html: species.info_text)
                        
                    }
                    // Add more Text views as needed for other properties
                    Link("More at waarneming.nl", destination: URL(string: species.permalink)!)
                } else {
                    Text("Loading")
                }
            }
        }
        .onAppear {
            log.error("Calling SpeciesDetailsView FetchData \(speciesID)")
            viewSDModel.fetchData(for: speciesID)
        }
    }
}

#Preview {
    SpeciesDetailsView(speciesID: 245)
        .environmentObject(Settings())
}
