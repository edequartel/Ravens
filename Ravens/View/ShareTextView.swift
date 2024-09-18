import SwiftUI
import Foundation

// ViewModel to manage image loading from sandbox
class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    // Method to load image from sandbox given an image name
    func loadImage(named imageName: String) {
        let fileManager = FileManager.default

        // Get the path to the sandbox's 'images' directory
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imagesDirectory = documentsPath.appendingPathComponent("images")
            let imagePath = imagesDirectory.appendingPathComponent(imageName)

            // Load the image if it exists
            if fileManager.fileExists(atPath: imagePath.path) {
                if let loadedImage = UIImage(contentsOfFile: imagePath.path) {
                    DispatchQueue.main.async {
                        self.image = loadedImage
                    }
                }
            } else {
                print("Image not found at path: \(imagePath.path)")
            }
        }
    }
}

// SwiftUI View to display the image
struct ShareTextView: View {
    let shareText: String
    let photo: String
    let subject: String
    let message: String
    
    init(shareText: String, photo: String, subject: String, message: String) {
        self.shareText = shareText
        self.photo = photo
        self.subject = subject
        self.message = message
    }
    
    
    @StateObject private var imageLoader = ImageLoader()
    @State private var imageName: String = "85834566.jpg" // Variable for the image name

    var body: some View {
        VStack {
            if let uiImage = imageLoader.image {
                let image = Image(uiImage: uiImage)

                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding()
                    
                Button("Load Image") {
                    imageLoader.loadImage(named: photo)
                }
                .padding()
                
                ShareLink(
                    item: image,
                    subject: Text(subject),
                    message: Text(message),
                    preview: SharePreview(subject, image: image)
                )
            } else {
                Text("Image not found")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            imageLoader.loadImage(named: photo)
        }
    }
    
//    var body: some View {
//        VStack {
//            if let uiImage = imageLoader.image {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 300, height: 300)
//                    .padding()
//            } else {
//                Text("Image not found")
//                    .foregroundColor(.red)
//            }
//            
//            Button("Load Image") {
//                imageLoader.loadImage(named: photo)
//            }
//            .padding()
//            
//            ShareLink(
//                item: Image(photo),
//                subject: Text(subject),
//                message: Text(message),
//                preview: SharePreview(subject, image: photo)
//            )
//            
//        }
//        .onAppear {
//            imageLoader.loadImage(named: photo)
//        }
//    }
}

// Entry point for the SwiftUI app
//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}





////
////  TestMe.swift
////  Ravens
////
////  Created by Eric de Quartel on 09/05/2024.
////
//
//
//
//import SwiftUI
//import Foundation
//
//// ViewModel to manage image loading from sandbox
//class ImageLoader: ObservableObject {
//    @Published var image: UIImage?
//
//    // Method to load image from sandbox given an image name
//    func loadImage(named imageName: String) {
//        let fileManager = FileManager.default
//
//        // Get the path to the sandbox's 'images' directory
//        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
//            let imagesDirectory = documentsPath.appendingPathComponent("images")
//            let imagePath = imagesDirectory.appendingPathComponent(imageName)
//
//            // Load the image if it exists
//            if fileManager.fileExists(atPath: imagePath.path) {
//                if let loadedImage = UIImage(contentsOfFile: imagePath.path) {
//                    DispatchQueue.main.async {
//                        self.image = loadedImage
//                    }
//                }
//            } else {
//                print("Image not found at path: \(imagePath.path)")
//            }
//        }
//    }
//}
//
//// SwiftUI View to display the image
//struct ContentView: View {
//    @StateObject private var imageLoader = ImageLoader()
//    @State private var imageName: String = "example.jpg" // Variable for the image name
//
//    var body: some View {
//        VStack {
//            if let uiImage = imageLoader.image {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 300, height: 300)
//                    .padding()
//            } else {
//                Text("Image not found")
//                    .foregroundColor(.red)
//            }
//            
//            Button("Load Image") {
//                imageLoader.loadImage(named: imageName)
//            }
//            .padding()
//        }
//        .onAppear {
//            imageLoader.loadImage(named: imageName)
//        }
//    }
//}
//
//// Entry point for the SwiftUI app
//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//
//struct ShareTextView: View {
//    // Define all properties as variables
//    let shareText: String
//    let photo: String
//    let subject: String
//    let message: String
//
//    init(shareText: String, photo: String, subject: String, message: String) {
//        self.shareText = shareText
//        self.photo = photo
//        self.subject = subject
//        self.message = message
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            VStack(alignment: .leading, spacing: 10) {
//                Image(photo)
//                    .resizable()
//                    .scaledToFit()
//                
//                ShareLink(
//                    item: Image(photo),
//                    subject: Text(subject),
//                    message: Text(message),
//                    preview: SharePreview(subject, image: photo)
//                )
//            }
//            .padding(.horizontal)
//        }
//        .padding()
//    }
//    
//    
//}
//
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
////}
