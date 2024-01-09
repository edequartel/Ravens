//
//  SpeciesDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import AlamofireImage
import RichText

struct SpeciesDetailsView: View {
    @ObservedObject var viewModel = SpeciesDetailsViewModel()
    
    var speciesID: Int // Add speciesID as a property

    init(speciesID: Int) {
        self.speciesID = speciesID
    }

    var body: some View {
        Form{
            VStack {
                if let species = viewModel.speciesDetails {
                    
                    if let imageUrl = URL(string: species.photo) {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
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
                    Text("Loading...")
                }
            }
        }
        .onAppear {
            viewModel.fetchData(for: speciesID)
        }
    }
}

#Preview {
    SpeciesDetailsView(speciesID: 8085)
}
