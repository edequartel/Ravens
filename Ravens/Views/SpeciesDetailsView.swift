//
//  SpeciesDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import AlamofireImage
import RichText
import SwiftyBeaver

struct SpeciesDetailsView: View {
    let log = SwiftyBeaver.self
//    @EnvironmentObject var viewSDModel: SpeciesDetailsViewModel
    @StateObject var viewSDModel = SpeciesDetailsViewModel()
    
    var speciesID: Int // Add speciesID as a property

    var body: some View {
        Form{
            VStack {
                if let species = viewSDModel.speciesDetails {
                    
                    if let imageUrl = URL(string: species.photo) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(nil, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
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
            viewSDModel.fetchData(for: speciesID)
        }
    }
}

#Preview {
    SpeciesDetailsView(speciesID: 245)
}
