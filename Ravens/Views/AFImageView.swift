//
//  AlamofireImage.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//


import SwiftUI
import Alamofire
import SwiftyBeaver

struct AFImageView: View {
    let log = SwiftyBeaver.self
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
//            print("\(media)")
            loadImageFromURL()
//            print("path: \(getDocumentsDirectory())")
        }
    }

    func loadImageFromURL() {
        guard let url = URL(string: media) else {
            return
        }

        let fileManager = FileManager.default
        let imagesDirectory = getDocumentsDirectory().appendingPathComponent("images")

        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        let path = imagesDirectory.appendingPathComponent(url.lastPathComponent)
//        print("path: \(path)")

        if let imageData = try? Data(contentsOf: path), let uiImage = UIImage(data: imageData) {
//            print("Loaded image from disk")
            self.downloadedImage = Image(uiImage: uiImage)
        } else {
            log.info("Downloading image from \(url)")
            AF.request(url).responseData { response in
                switch response.result {
                case .success(let data):
                    if let uiImage = UIImage(data: data) {
                        self.downloadedImage = Image(uiImage: uiImage)
                        try? data.write(to: path)
                    }
                case .failure(let error):
                    log.error("Error downloading image: \(error)")
                }
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        AFImageView(media: "https://waarneming.nl/media/photo/84399858.jpg")
    }
}
