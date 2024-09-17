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
    @State var photos: [String]?
    @Binding var imageURLStr: String?

    let columns = [
        GridItem(.flexible()), // First column
        GridItem(.flexible()), // Second column
        GridItem(.flexible()), // Third column
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(photos ?? [], id: \.self) { photo in
                    CachedAsyncImage(url: URL(string: photo)!) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity) // Height will adapt to the image
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .onTapGesture {
                                    imageURLStr = photo // Update the binding with the selected image URL
                                }
                        case .failure:
                            Image(systemName: "xmark.circle")
                                .frame(maxWidth: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(8)
        }
        .sheet(item: $imageURLStr) { imageURLStr in
            if let imageURL = URL(string: imageURLStr) {
                CachedAsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .failure:
                        Image(systemName: "xmark.circle")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .animation(.default, value: photos?.count) // Smooth animation for dynamic changes in grid size
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


