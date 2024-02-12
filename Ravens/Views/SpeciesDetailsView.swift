//
//  SpeciesDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import RichText
import SwiftyBeaver
import Kingfisher

struct SpeciesDetailsView: View {
    let log = SwiftyBeaver.self
//    @EnvironmentObject var viewSDModel: SpeciesDetailsViewModel
    @StateObject var viewSDModel = SpeciesDetailsViewModel()
    @EnvironmentObject var settings: Settings
    
    var speciesID: Int // Add speciesID as a property

    var body: some View {
        Form{
            VStack {
                if let species = viewSDModel.speciesDetails {
                    KFImage(URL(string: species.photo)!)
                        .resizable()
                        .aspectRatio(nil, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text(species.name)
                            .font(.title)
                        Text(species.scientific_name)
                        Text(species.group_name)
                        Text(species.status)
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
            viewSDModel.fetchData(for: speciesID, language: settings.selectedLanguage)
        }
    }
}

#Preview {
    SpeciesDetailsView(speciesID: 245)
}
