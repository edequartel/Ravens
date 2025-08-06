//
//  FlashCard.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/08/2025.
//

import SwiftUI
import AVFoundation

struct BirdFlashcardView: View {
  var speciesNames: [SpeciesName]
  var showScientificNameFirst: Bool

  @State private var currentSpeciesName: SpeciesName = SpeciesName(commonName: "", scientificName: "")
  @State private var isFlipped: Bool = false
  @State private var rotation: Double = 0

  var body: some View {
    NavigationStack {
      VStack(spacing: 40) {
        Spacer()

        ZStack {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(isFlipped ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
            .frame(height: 200)
            .overlay(
              Text(displayedText())
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .rotation3DEffect(.degrees(-rotation), axis: (x: 0, y: 1, z: 0)) // Counter rotation
            )
            
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
//              withAnimation(.easeInOut(duration: 0.1)) {
                rotation += 180
                isFlipped.toggle()
//              }
            }
        }
        .padding(.horizontal)

        Button(action: {
          showNextCard()
        }) {
          HStack {
            Image(systemName: "arrow.right.circle.fill")
            Text("Volgende")
          }
        }
        .buttonStyle(CapsuleButtonStyle())

        Spacer()
      }
      .padding()
      .islandBackground()
      .onAppear {
        showNextCard()
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          ShareLink(
            item: String(localized: "aiChat") + " " + currentSpeciesName.scientificName
          ) {
            SVGImage(svg: "artificialintel")
          }
        }
      }
    }
  }

  func displayedText() -> String {
    if showScientificNameFirst {
      return isFlipped ? currentSpeciesName.commonName : currentSpeciesName.scientificName
    } else {
      return isFlipped ? currentSpeciesName.scientificName : currentSpeciesName.commonName
    }
  }

  func showNextCard() {
    currentSpeciesName = speciesNames.randomElement() ?? SpeciesName(commonName: "", scientificName: "")
    isFlipped = false
    rotation = 0
  }
}
