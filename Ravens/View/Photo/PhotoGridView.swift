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

struct PhotoGridView: View {
  @State var photos: [String] = []
  @State private var isImagePresented = false

  let adaptiveColumns = [
    GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: adaptiveColumns, spacing: 16) {
        ForEach(photos, id: \.self) { photo in
          KFImage(URL(string: photo))
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
              isImagePresented = true
            }
            .padding(4)
        }
      }
      .padding(.horizontal, 8)
    }
    .sheet(isPresented: $isImagePresented) {
      PhotoGridViewLP(photos: photos)
        .presentationDragIndicator(.visible)
    }
  }
}


struct PhotoGridViewLP: View {
  @State var photos: [String] = []
  var body: some View {
    VStack {
      LazyPager(data: photos) { photo in
          KFImage(URL(string: photo))
              .resizable()
              .scaledToFit()
      }
      .zoomable(min: 1, max: 5)
    }
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

