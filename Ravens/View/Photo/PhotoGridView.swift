//
//  PhotoGridView.swift
//  Ravens
//
//  Created by Eric de Quartel on 01/10/2024.
//

import SwiftUI
import SwiftyBeaver
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
    GridItem(.flexible())  // Third column
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(photos, id: \.self) { photo in
          KFImage(URL(string: photo))
            .resizable()    // Make the image resizable
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
              imageURLStr = photo
            }
            .padding(4)
            .sheet(item: $imageURLStr) { imageURLStr in
              myImageView(StringURL: imageURLStr)
                .presentationDragIndicator(.visible)
            }
        }
      }
    }
  }
}


struct PhotoGridView_Previews: PreviewProvider {
    static var previews: some View {
      PhotoGridView(photos: [
        "https://waarneming.nl/media/photo/84399858.jpg",
        "https://waarneming.nl/media/photo/84399859.jpg",
        "https://waarneming.nl/media/photo/84399860.jpg"],
                    imageURLStr: .constant(""))
    }
}