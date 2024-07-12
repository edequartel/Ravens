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
import Kingfisher
import SwiftUIImageViewer


struct AFImageView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var settings: Settings
    
    @State private var downloadedImage: SwiftUI.Image? = nil
    @State private var isImagePresented = false
    
    @State private var alertType: AlertType? = nil

    enum AlertType: Identifiable {
        case success
        case failure

        var id: Int {
            switch self {
            case .success:
                return 1
            case .failure:
                return 2
            }
        }
    }
    
    @State private var imageName: String = ""

    var media: String
    
    var body: some View {
        VStack {
            if let image = downloadedImage {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .onTapGesture {
                        isImagePresented = true
                        print("pressed \(media)")
                    }
            } else {
                ProgressView()
            }
        }
//        .fullScreenCover(isPresented: $isImagePresented) {
        .sheet(isPresented: $isImagePresented) {
//            Imagexx(media)
            SwiftUIImageViewer(image: image)
                                .overlay(alignment: .topTrailing) {
                                    closeButtonX
                                }
            
            
//            VStack {
//                KFImage(URL(string: media))
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .scaledToFit()
//                    .ignoresSafeArea()
//                    .overlay(closeButton, alignment: .topLeading)
//                    .overlay(saveButton, alignment: .topTrailing)
//                    .onTapGesture {
//                        isImagePresented = false
//                    }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black.opacity(0.9))
//            .ignoresSafeArea()
//            .alert(item: $alertType) { type in
//                switch type {
//                case .success:
//                    return Alert(
//                        title: Text("Information"),
//                        message: Text("Image is saved to Album Ravens"),
//                        dismissButton: .default(Text("OK"))
//                    )
//                case .failure:
//                    return Alert(
//                        title: Text("Error"),
//                        message: Text("Image is NOT saved to Album Ravens"),
//                        dismissButton: .default(Text("OK"))
//                    )
//                }
//            }
            
        }
        .onAppear {
            loadImageFromURL()
        }
    }
    
    private var image: Image {
        let filename = URL(string: media)?.lastPathComponent
        let filePath = getDocumentsDirectory().appendingPathComponent("images/\(filename ?? "")")
        let uiImage = UIImage(contentsOfFile: filePath.path)
        return Image(uiImage: uiImage ?? UIImage(systemName: "photo")!)
    }
    
    private var closeButtonX: some View {
            Button {
                isImagePresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
            .tint(.purple)
            .padding()
        }
    
    private var closeButton: some View {
        Button {
            isImagePresented = false
        } label: {
            Image(systemName: "arrow.backward.square.fill")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.bordered)
        .clipShape(Circle())
        .padding()
    }
    
    private var saveButton: some View {
        Button {
            log.info("Save image")
            guard let url = URL(string: media) else { return }
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    let image = value.image
                    log.info("Successfully retrieved image")
                    saveImageToAlbum(image: image, albumName: "Ravens") { success, error in
                        if success {
                            log.info("Image saved")
                            alertType = .success
                        } else {
                            log.error("Error saving image: \(String(describing: error))")
                            alertType = .failure
                        }
                    }
                case .failure(let error):
                    log.error("Error retrieving image: \(error)")
                    alertType = .failure
                }
            }
        } label: {
            Image(systemName: "arrow.down.to.line.square.fill")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.bordered)
        .clipShape(Circle())
        .padding()
    }
    
    func loadImageFromURL() {
        guard let url = URL(string: media) else {
            log.error("Invalid URL")
            return
        }
        
        let fileManager = FileManager.default
        let imagesDirectory = getDocumentsDirectory().appendingPathComponent("images")
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        let path = imagesDirectory.appendingPathComponent(url.lastPathComponent)
        imageName = url.lastPathComponent
        
        log.info("Image path: \(url.lastPathComponent)")
        
        if let imageData = try? Data(contentsOf: path), let uiImage = UIImage(data: imageData) {
            log.info("Loaded image from disk")
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
        return paths[0]
    }
    
    func saveImageToAlbum(image: UIImage, albumName: String, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false, NSError(domain: "PhotoLibraryAccess", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photo library access is not authorized."]))
                return
            }
            
            var albumPlaceholder: PHObjectPlaceholder?
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = collection.firstObject {
                saveImage(image: image, to: album)
                completion(true, nil)
            } else {
                PHPhotoLibrary.shared().performChanges({
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }) { success, error in
                    if success, let placeholder = albumPlaceholder {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                        if let album = collectionFetchResult.firstObject {
                            saveImage(image: image, to: album)
                            completion(true, nil)
                        }
                    } else {
                        log.error("Error creating album: \(String(describing: error))")
                        completion(false, error)
                    }
                }
            }
        }
    }
    
    func saveImage(image: UIImage, to album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                  let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset else { return }
            albumChangeRequest.addAssets([assetPlaceholder] as NSArray)
        }) { success, error in
            if success {
                log.info("Successfully added image to \(album.localizedTitle ?? "")")
            } else {
                log.error("Error adding image to album: \(String(describing: error))")
            }
        }
    }
}

struct PhotoGridView: View {
    var photos: [String]?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(photos ?? [], id: \.self) { imageURLString in
                    AFImageView(media: imageURLString)
                }
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        AFImageView(media: "https://waarneming.nl/media/photo/84399858.jpg")
            .environmentObject(Settings()) // Ensure the Settings object is provided
    }
}
