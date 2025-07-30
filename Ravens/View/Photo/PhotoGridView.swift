//
//  PhotoGridView.swift
//  Ravens
//
//  Created by Eric de Quartel on 01/10/2024.
//

import SwiftUI
import SwiftyBeaver
import Kingfisher
import LazyPager

import WaterfallGrid
import ZoomImageView

struct PhotoGridView: View {
  @State var photos: [String] = []
  @State private var isImagePresented = false
  @State private var selectedPhoto: String? = nil
  @State private var imageSizes: [String: CGSize] = [:]

  var body: some View {
    ScrollView {
      WaterfallGrid(photos, id: \.self) { photo in
        GeometryReader { geometry in
          VStack {
            KFImage(URL(string: photo))
              .onSuccess { result in
                // Save the image size on load
                DispatchQueue.main.async {
                  imageSizes[photo] = result.image.size
                }
              }
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: geometry.size.width)
              .cornerRadius(4)
          }
          .frame(width: geometry.size.width)
          .background(Color(.secondarySystemBackground))
          .cornerRadius(12)
//          .shadow(radius: 2)
          .onTapGesture {
            selectedPhoto = photo
            isImagePresented = true
          }
        }
        .frame(height: getHeight(for: photo, in: UIScreen.main.bounds.width / 2 - 24))
      }
      .gridStyle(
        columnsInPortrait: 2,
        columnsInLandscape: 3,
        spacing: 12,
        animation: .easeInOut(duration: 0.3)
      )
      .padding()
    }
//    .sheet(isPresented: $isImagePresented) {
//      if let selected = selectedPhoto {
//        FullscreenPhotoView(photoURL: selected)
//      }
//    }
  }

  // Use stored size to calculate height dynamically
  private func getHeight(for photo: String, in width: CGFloat) -> CGFloat {
    guard let size = imageSizes[photo] else {
      return 200 // default until image loads
    }
    let aspectRatio = size.height / size.width
    return width * aspectRatio
  }

}


struct PhotoGridView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoGridView(
      photos: [
        "https://waarneming.nl/media/photo/84399858.jpg",
        "https://waarneming.nl/media/photo/84399859.jpg",
        "https://waarneming.nl/media/photo/84399860.jpg"
      ]
    )
  }
}
