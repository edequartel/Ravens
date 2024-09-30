//
//  PhotoGridView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//

import SwiftUI
import SwiftyBeaver
import CachedAsyncImage
import Kingfisher

struct PhotoGridView: View {
  @State var photos: [String] = []
  @Binding var imageURLStr: String?

  @State private var zoomScale: CGFloat = 1.0
  @State private var dragOffset: CGSize = .zero
  @State private var finalOffset: CGSize = .zero

  @State private var isImagePresented = false

  let columns = [
    GridItem(.flexible()), // First column
    GridItem(.flexible()), // Second column
    GridItem(.flexible()), // Third column
    GridItem(.flexible())
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(photos.indices, id: \.self) { index in
          let photo = photos[index]
          KFImage(URL(string: photo))
            .resizable()    // Make the image resizable
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.leading, index % 4 != 0 ? 16 : 0) // No left padding for the first image
            .padding(.trailing, index % 4 != 3 ? 16 : 0) // No right padding for the fourth image
            .onTapGesture {
              imageURLStr = photo
            }
            .sheet(item: $imageURLStr) { imageURLStr in
              myImageView(StringURL: imageURLStr)
                .presentationDragIndicator(.visible)
            }
        }
//        ForEach(photos.indices, id: \.self) { index in
//          let photo = photos[index]
//          KFImage(URL(string: photos?.first ?? ""))
//            .resizable()    // Make the image resizable
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 80, height: 80)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .onTapGesture {
//              imageURLStr = photos?.first ?? ""
//            }
//            .sheet(item: $imageURLStr) { imageURLStr in
//              myImageView(StringURL: imageURLStr)
//                .presentationDragIndicator(.visible)
//            }
//        }
      }
    }
  }
}

struct myImageView: View {
  var StringURL: String = "https://waarneming.nl/media/photo/84399858.jpg"

  @State private var currentAmount: CGFloat = 1
  @State private var currentPosition: CGSize = .zero
  @State private var newPosition: CGSize = .zero

  var body: some View {
    KFImage(URL(string: StringURL))
        .resizable()
        .aspectRatio(contentMode: .fit)
        .scaleEffect(currentAmount)
        .offset(x: self.newPosition.width, y: self.newPosition.height)
        .gesture(
            MagnificationGesture().onChanged { amount in
                self.currentAmount = amount
            }
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                }
                .onEnded { value in
                    self.newPosition = self.currentPosition
                }
        )
  }

}

struct PhotoThumbnailView: View {
  var photos: [String]?
  @Binding var imageURLStr: String?

  // Get the screen's width and height
  let screenWidth = UIScreen.main.bounds.width
  let screenHeight = UIScreen.main.bounds.height
  let downSize = 0.2

  var body: some View {
    LazyHStack {
      if (photos?.first) != nil {
        KFImage(URL(string: photos?.first ?? ""))
        .resizable()    // Make the image resizable
        .aspectRatio(contentMode: .fill)
        // Set the frame width and height as a fraction of the screen size
        .frame(width: screenWidth * downSize, height: screenWidth * downSize)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      } else {
        ImageWithOverlay(systemName: "photo", value: false)
          // Set the frame width and height as a fraction of the screen size
          .frame(width: screenWidth * downSize, height: screenWidth * downSize)
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
    PhotoThumbnailView(photos: photos, imageURLStr: .constant(""))
  }
}


