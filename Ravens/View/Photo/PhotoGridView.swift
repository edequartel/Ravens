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
// import Zoomable

struct PhotoGridView: View {
  @State var photos: [String] = []
  @State private var imageSizes: [String: CGSize] = [:]
  @State private var showPager: Bool = false
  @State private var selectedIndex: Int = 0

  var body: some View {
    NavigationStack {
      ScrollView {
        WaterfallGrid(photos, id: \.self) { photo in
          GeometryReader { geometry in
            let idx = photos.firstIndex(of: photo) ?? 0
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
              .background(Color.clear) // prevent implicit island effect
              .contentShape(Rectangle())
              .onTapGesture {
                selectedIndex = idx
                showPager = true
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
        .fullScreenCover(isPresented: $showPager) {
          ImagePagerView(imageURLs: photos.compactMap { URL(string: $0) },
                         isPresented: $showPager,
                         startIndex: selectedIndex)
        }
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

struct ImagePagerView: View {
    let imageURLs: [URL]
    @Binding var isPresented: Bool
    let startIndex: Int

    @State private var currentIndex: Int = 0
    @State private var isZoomed: Bool = false

    private var clampedStartIndex: Int {
        guard !imageURLs.isEmpty else { return 0 }
        return min(max(0, startIndex), imageURLs.count - 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(imageURLs.indices, id: \.self) { idx in
                        KFZoomableImage(url: imageURLs[idx], isZoomed: $isZoomed)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(Color.black)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                // Top overlay: close + share
                VStack {
                    HStack {
                        Button { isPresented = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                                .padding(12)
                        }
                        Spacer()
                        if imageURLs.indices.contains(currentIndex) {
                            ShareLink(item: imageURLs[currentIndex]) {
                                Image(systemName: "square.and.arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white)
                                    .padding(12)
                            }
                        }
                    }
                    Spacer()
                }

                // Bottom overlay: index
                VStack {
                    Spacer()
                    if imageURLs.count > 1 {
                        Text("\(currentIndex + 1) / \(imageURLs.count)")
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(.white)
                            .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            currentIndex = clampedStartIndex
        }
        .onChange(of: startIndex) { _, _ in
            currentIndex = clampedStartIndex
        }
        .onChange(of: currentIndex) { _, _ in
            isZoomed = false
        }
    }
}

struct KFZoomableImage: View {
    let url: URL
    @Binding var isZoomed: Bool

    @State private var imageSize: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                KFImage(url)
                    .onSuccess { result in
                        imageSize = result.image.size
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = clampedScale(lastScale * value)
                                isZoomed = scale > 1.01
                            }
                            .onEnded { _ in
                                scale = clampedScale(scale)
                                lastScale = scale
                                offset = clampedOffset(for: offset, in: geometry.size, scale: scale)
                                lastOffset = offset
                                isZoomed = scale > 1.01
                            }
                    )
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard scale > 1.01 else { return }
                                let proposedOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                offset = clampedOffset(for: proposedOffset, in: geometry.size, scale: scale)
                                isZoomed = true
                            }
                            .onEnded { value in
                                guard scale > 1.01 else { return }
                                let projectedOffset = CGSize(
                                    width: lastOffset.width + value.predictedEndTranslation.width,
                                    height: lastOffset.height + value.predictedEndTranslation.height
                                )
                                offset = clampedOffset(for: projectedOffset, in: geometry.size, scale: scale)
                                lastOffset = offset
                                isZoomed = true
                            },
                        including: scale > 1.01 ? .all : .none
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            if scale > 1.01 {
                                resetZoom()
                            } else {
                                scale = 2.5
                                lastScale = scale
                                offset = .zero
                                lastOffset = .zero
                                isZoomed = true
                            }
                        }
                    }
            }
        }
        .onChange(of: isZoomed) { _, newValue in
            if !newValue {
                resetZoom()
            }
        }
    }

    private func clampedScale(_ value: CGFloat) -> CGFloat {
        min(max(value, 1.0), 5.0)
    }

    private func clampedOffset(for offset: CGSize, in size: CGSize, scale: CGFloat) -> CGSize {
        let fittedSize = fittedImageSize(in: size)
        let maxX = max(0, (fittedSize.width * scale - size.width) / 2)
        let maxY = max(0, (fittedSize.height * scale - size.height) / 2)
        return CGSize(width: max(min(offset.width, maxX), -maxX),
                      height: max(min(offset.height, maxY), -maxY))
    }

    private func fittedImageSize(in containerSize: CGSize) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0,
              containerSize.width > 0, containerSize.height > 0 else {
            return containerSize
        }

        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height

        if imageAspect > containerAspect {
            return CGSize(width: containerSize.width, height: containerSize.width / imageAspect)
        } else {
            return CGSize(width: containerSize.height * imageAspect, height: containerSize.height)
        }
    }

    private func resetZoom() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        isZoomed = false
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
