//
//  AlamofireImage.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//


import SwiftUI
import Alamofire
import SwiftyBeaver
import Photos

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
                        
                        saveImageToAlbum(image: uiImage, albumName: "Ravens")

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
    
    func saveImageToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Need authorization to access the photo library")
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    func saveImageToAlbum(image: UIImage, albumName: String) {
        // Request authorization to access photo library
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Check if album exists
                var albumPlaceholder: PHObjectPlaceholder?
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                
                if let album = collection.firstObject {
                    // Album exists, save image directly
                    saveImage(image: image, to: album)
                } else {
                    // Album does not exist, create new album
                    PHPhotoLibrary.shared().performChanges({
                        let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                        albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                    }) { success, error in
                        if success {
                            let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder!.localIdentifier], options: nil)
                            let album = collectionFetchResult.firstObject
                            saveImage(image: image, to: album!)
                        } else {
                            print("Error creating album: \(String(describing: error))")
                        }
                    }
                }
            }
        }
    }

    func saveImage(image: UIImage, to album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                  let photoPlaceholder = assetPlaceholder else { return }
            let enumeration: NSArray = [photoPlaceholder]
            albumChangeRequest.addAssets(enumeration)
        }) { success, error in
            if success {
                log.info("Successfully added image to \(album.localizedTitle ?? "")")
            } else {
                log.error("Error adding image to album: \(String(describing: error))")
            }
        }
    }

    
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        AFImageView(media: "https://waarneming.nl/media/photo/84399858.jpg")
    }
}
