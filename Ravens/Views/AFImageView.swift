//
//  AlamofireImage.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//


import SwiftUI
import Alamofire
//import AlamofireImage

struct AFImageView: View {
    @State private var downloadedImage: SwiftUI.Image? = nil
    
    var media: String

    var body: some View {
        VStack {
            if let image = downloadedImage {
                image
                    .resizable()
                    .aspectRatio(nil, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadImageFromURL()
        }
    }

    func loadImageFromURL() {
        guard let url = URL(string: media) else {
            return
        }

        AF.request(url).responseImage { response in
            switch response.result {
            case .success(let uiImage):
                self.downloadedImage = SwiftUI.Image(uiImage: uiImage)
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        AFImageView(media: "https://waarneming.nl/media/photo/84399858.jpg")
    }
}
