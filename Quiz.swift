//
//  Quiz.swift
//  Ravens
//
//  Created by Eric de Quartel on 01/08/2025.
//

import SwiftUI
import AVFoundation

@MainActor
class QuizViewModel: ObservableObject {
  let speciesNames: [SpeciesName]
  let totalQuestions = 10

  @Published var currentSpeciesName: SpeciesName = SpeciesName(commonName: "", scientificName: "")
  @Published var options: [SpeciesName] = []
  @Published var feedback: String = ""
  @Published var showNext = false
  @Published var score: Int = 0
  @Published var questionCount: Int = 0
  @Published var isFlippedMode: Bool = false
  @Published var timeRemaining: Int = 10
  @Published var isFinished: Bool = false

  private var player: AVAudioPlayer?

  init(speciesNames: [SpeciesName]) {
    self.speciesNames = speciesNames
    loadQuestion(increment: false)
  }

  func loadQuestion(increment: Bool = true) {
    if increment {
      questionCount += 1
    }

    if questionCount >= totalQuestions {
      isFinished = true
      return
    }

    feedback = ""
    showNext = false
    timeRemaining = 10

    currentSpeciesName = speciesNames.randomElement() ?? SpeciesName(commonName: "", scientificName: "")
    updateOptions()
  }

  func updateOptions() {
    let correct = currentSpeciesName
    let wrongOptions = speciesNames
      .filter { $0.id != correct.id }
      .shuffled()
      .prefix(3)

    options = (wrongOptions + [correct]).uniqued().shuffled()
  }

  func checkAnswer(_ selected: SpeciesName) {
    let correct = isFlippedMode ? currentSpeciesName.commonName : currentSpeciesName.scientificName
    let answer = isFlippedMode ? selected.commonName : selected.scientificName

    if answer == correct {
      feedback = "Correct!"
      score += 1
      playSound(named: "correct")
    } else {
      feedback = correct
      playSound(named: "wrong")
    }
    showNext = true
  }

  func tickTimer() {
    guard !showNext && !isFinished else { return }

    if timeRemaining > 0 {
      timeRemaining -= 1
    } else {
      feedback = isFlippedMode ? currentSpeciesName.commonName : currentSpeciesName.scientificName
      showNext = true
      playSound(named: "wrong")
    }
  }

  func restart() {
    score = 0
    questionCount = 0
    isFinished = false
    loadQuestion(increment: false)
  }

  private func playSound(named name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
    player = try? AVAudioPlayer(contentsOf: url)
    player?.play()
  }
}

import SwiftUI

struct BirdQuizView: View {
  var speciesNames: [SpeciesName]

  @StateObject private var viewModel: QuizViewModel
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init(speciesNames: [SpeciesName]) {
      self.speciesNames = speciesNames 
      _viewModel = StateObject(wrappedValue: QuizViewModel(speciesNames: speciesNames))
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        if viewModel.isFinished {
          Text("Klaar!")
            .font(.largeTitle)
          Text("Je score: \(viewModel.score) / \(viewModel.totalQuestions)")
            .font(.title2)
            .foregroundColor(.blue)
          Button("Opnieuw") {
            viewModel.restart()
          }
          .buttonStyle(CapsuleButtonStyle())
        } else {
          quizBody
        }
      }
      .padding()
      .islandBackground()
      .onReceive(timer) { _ in
        viewModel.tickTimer()
      }
    }
  }

  var quizBody: some View {
    VStack(spacing: 16) {
      HStack(spacing: 20) {
        Label("Vraag \(viewModel.questionCount + 1)/\(viewModel.totalQuestions)", systemImage: "questionmark.circle")
        Label("Score: \(viewModel.score)", systemImage: "checkmark.seal")
      }

      Text("\(viewModel.timeRemaining)")
        .font(.title)

      Text(viewModel.isFlippedMode ? viewModel.currentSpeciesName.scientificName : viewModel.currentSpeciesName.commonName)
        .font(.largeTitle)
        .multilineTextAlignment(.center)

      Spacer()

      if viewModel.showNext {
        Button {
          viewModel.loadQuestion()
        } label: {
          Label("Next", systemImage: "arrow.right.circle.fill")
        }
        .buttonStyle(CapsuleButtonStyle())
      }

      Spacer()

      ForEach(viewModel.options, id: \.id) { option in
        let answerText = viewModel.isFlippedMode ? option.commonName : option.scientificName
        Button {
          viewModel.checkAnswer(option)
        } label: {
          Text(answerText)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              Group {
                if viewModel.showNext && option.id == viewModel.currentSpeciesName.id {
                  (viewModel.feedback == "Correct!" ? Color.green : Color.red)
                } else {
                  Color.clear
                }
              }
            )
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        }
        .disabled(viewModel.showNext)
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.isFlippedMode.toggle()
          viewModel.updateOptions()
        } label: {
          Image(systemName: viewModel.isFlippedMode ? "checkmark.square" : "square")
            .uniformSize()
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        let localizedIntro = String(localized: "aiChat") // bijv. "Praat met AI over:"
        let message = "\(localizedIntro) \(viewModel.currentSpeciesName.scientificName)"

        ShareLink(item: message) {
          SVGImage(svg: "artificialintel")
        }
      }
    }
  }
}
