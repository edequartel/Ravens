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
import Zoomable

struct PhotoGridView: View {
  @State var photos: [String] = []
  @State private var selectedPhoto: String?
  @State private var imageSizes: [String: CGSize] = [:]

  var body: some View {
    ScrollView {
      WaterfallGrid(photos, id: \.self) { photo in
        GeometryReader { geometry in
          VStack {
            KFImage(URL(string: photo))
              .onSuccess { result in
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
          .onTapGesture {
//            NavigationLink(destination: KFImageFullScreen(urlString: photo)) {
//              KFImageFullScreen(urlString: photo)
//            }
            print("selected \(photo)")
            selectedPhoto = photo
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
    .sheet(item: $selectedPhoto) { photo in
      VStack {
//        Text("Selected photo: \(photo)")
        KFImageFullScreen(urlString: photo)
      }
    }
  }

  private func getHeight(for photo: String, in width: CGFloat) -> CGFloat {
    guard let size = imageSizes[photo] else {
      return 200
    }
    let aspectRatio = size.height / size.width
    return width * aspectRatio
  }
}

//import SwiftUI
//import Kingfisher

struct KFImageFullScreen: View {
    let urlString: String

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if let url = URL(string: urlString) {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        scale = min(max(scale, 1.0), 5.0)
                                        lastScale = scale
                                        offset = clampedOffset(for: offset, in: geometry.size, scale: scale)
                                        lastOffset = offset
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { value in
                                        offset = clampedOffset(for: offset, in: geometry.size, scale: scale)
                                        lastOffset = offset
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }

                } else {
                    Text("Invalid image URL")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            print("Loaded image: \(urlString)")
        }
    }

    private func clampedOffset(for offset: CGSize, in size: CGSize, scale: CGFloat) -> CGSize {
        let maxX = (scale - 1) * size.width / 2
        let maxY = (scale - 1) * size.height / 2
        return CGSize(
            width: max(min(offset.width, maxX), -maxX),
            height: max(min(offset.height, maxY), -maxY)
        )
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
