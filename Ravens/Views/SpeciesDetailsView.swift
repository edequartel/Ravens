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
    @ObservedObject var viewModel = SpeciesDetailsViewModel()
    
    var speciesID: Int // Add speciesID as a property

    var body: some View {
        Form{
            VStack {
                if let species = viewModel.speciesDetails {
                    
                    if let imageUrl = URL(string: species.photo) {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
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
//        .padding(16)
//        .background(Color.white.cornerRadius(18))
//        .shadowedStyle()
//        .padding(.horizontal, 8)
//        .padding(.bottom, 30)
        
        .onAppear {
            log.error("Calling SpeciesDetailsView FetchData \(speciesID)")
            viewModel.fetchData(for: speciesID)
        }
    }
}

#Preview {
    SpeciesDetailsView(speciesID: 8085)
}
