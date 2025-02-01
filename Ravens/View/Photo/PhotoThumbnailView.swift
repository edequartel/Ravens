//
//  PhotoGridView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/02/2024.
//

import SwiftUI
import SwiftyBeaver
import Kingfisher

struct MyImageView: View {
  var stringURL: String = "https://waarneming.nl/media/photo/84399858.jpg"

  @State private var currentAmount: CGFloat = 1
  @State private var currentPosition: CGSize = .zero
  @State private var newPosition: CGSize = .zero

  var body: some View {
    KFImage(URL(string: stringURL))
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
    //    ZStack(alignment: .bottomTrailing) {
    LazyHStack {
      if (photos?.first) != nil {

        ZStack(alignment: .bottomTrailing) {
          KFImage(URL(string: photos?.first ?? ""))
            .resizable()    // Make the image resizable
            .aspectRatio(contentMode: .fill)
          // Set the frame width and height as a fraction of the screen size
            .frame(width: screenWidth * downSize, height: screenWidth * downSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
          //

          if photos?.count ?? 0 > 1 {
            Text("\(photos?.count ?? 0)")
              .font(.caption)
              .foregroundColor(.white)
              .padding([.trailing, .bottom],8)
          }
        }

        //

      } else {
        ImageWithOverlay(systemName: "photo", value: false)
        // Set the frame width and height as a fraction of the screen size
          .frame(width: screenWidth * downSize, height: screenWidth * downSize)
          .foregroundColor(.gray) // You can change the color if needed
      }
    }

    //      if photos?.count ?? 0 > 1 {
    //        Text("\(photos?.count ?? 0)")
    //          .font(.caption)
    //          .foregroundColor(.white)
    //          .padding([.trailing, .bottom],8)
    //      }
    //    }
  }
}


struct PhotoThumbnaiView_Previews: PreviewProvider {
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


