//
//  PhotoGridView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//

import SwiftUI
import SwiftyBeaver
import CachedAsyncImage
import LazyPager

struct PhotoGridView: View {
    @State var photos: [String]?
    @Binding var imageURLStr: String?

    let columns = [
        GridItem(.flexible()), // First column
        GridItem(.flexible()), // Second column
        GridItem(.flexible()),  // Third column
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


//struct PhotoGridView: View {
//    @State var photos: [String]?
//    @Binding var imageURLStr: String?
//
//    let columns = [
//        GridItem(.flexible()), // First column
//        GridItem(.flexible()), // Second column
//        GridItem(.flexible())  // Third column
//    ]
//
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: 16) {
//                ForEach(photos ?? [], id: \.self) { photo in
//                    CachedAsyncImage(url: URL(string: photo)!) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(maxWidth: .infinity, maxHeight: 120)
//                                .onTapGesture {
//                                    imageURLStr = photo // Update the binding with the selected image URL
//                                }
//                        case .failure:
//                            Image(systemName: "xmark.circle")
//                                .frame(maxWidth: .infinity, maxHeight: 120)
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                }
//            }
//            .padding(8)
//        }
//    }
//}


//struct PhotoGridView: View {
//  @State var photos: [String]?
//  @Binding var imageURLStr: String?
//
//  var body: some View {
//    LazyPager(data: photos ?? []) { photo in
//      CachedAsyncImage(url: URL(string: photo)!) { phase in
//        switch phase {
//        case .empty:
//          ProgressView()
//        case .success(let image):
//          image
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//        case .failure:
//          Image(systemName: "xmark.circle")
//        @unknown default:
//          EmptyView()
//        }
//      }
//    }
//    .zoomable(min: 1, max: 5)
//    .padding(8)
//  }
//}



struct PhotoGridView4: View {
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


