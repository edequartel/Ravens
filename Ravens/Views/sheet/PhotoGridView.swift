//
//  PhotoGridView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//

import SwiftUI
import SwiftyBeaver
import CachedAsyncImage

struct PhotoGridView: View {
  var photos: [String]?
  @Binding var imageURLStr: String?

  var body: some View {
    if photos == nil || photos?.count == 0 {
      EmptyView()
    } else {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack {
          ForEach(photos ?? [], id: \.self) { imageURLString in
            if let imageURL = URL(string: imageURLString) {
              CachedAsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                  ProgressView() // Show a progress indicator while loading
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                  image
                    .resizable()    // Make the image resizable
                    .aspectRatio(contentMode: .fill)
                  
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                      print("pressed \(imageURLString)")
                      imageURLStr = imageURLString
                    }
                case .failure:
                  Image(systemName: "xmark.circle") // Show an error image if loading fails
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                  EmptyView()
                }
              }
            }
          }
        }
      }
      .frame(height: 160)
    }
    
  }
}

struct PhotoView: View {
  var photos: [String]?
  @Binding var imageURLStr: String?

  var body: some View {
    LazyHStack {
      if let firstImageURLString = photos?.first, let imageURL = URL(string: firstImageURLString) {
        CachedAsyncImage(url: imageURL) { phase in
          switch phase {
          case .empty:
            ProgressView() // Show a progress indicator while loading
              .frame(width: 80, height: 80)
          case .success(let image):
            image
              .resizable()    // Make the image resizable
              .aspectRatio(contentMode: .fill)
              .frame(width: 80, height: 80)
              .clipShape(RoundedRectangle(cornerRadius: 8))
          case .failure:
            Image(systemName: "xmark.circle") // Show an error image if loading fails
              .frame(width: 80, height: 80)
          @unknown default:
            EmptyView()
          }
        }
      } else {
        ImageWithOverlay(systemName: "photo", value: false)
          .frame(width: 80, height: 80)
          .foregroundColor(.gray) // You can change the color if needed
      }
    }
  }
}

struct PhotoView_Previews: PreviewProvider {
  // Create some static data for the preview
  static let photos = [
    "https://waarneming.nl/media/photo/84399858.jpg",
    "https://waarneming.nl/media/photo/84399859.jpg",
    "https://waarneming.nl/media/photo/84399860.jpg"
  ]
  static var previews: some View {
    PhotoView(photos: photos, imageURLStr: .constant(""))
  }
}


