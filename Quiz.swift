////
////  Quiz.swift
////  Ravens
////
////  Created by Eric de Quartel on 01/08/2025.
////
//
//import SwiftUI
//import AVFoundation

import Foundation
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
        }
      }
    }
  }
}

//
//struct BirdQuizView: View {
//  var speciesNames: [SpeciesName]
//
//  @State private var currentSpeciesName: SpeciesName = SpeciesName(commonName: "", scientificName: "")
//  @State private var options: [SpeciesName] = []
//  @State private var feedback: String = ""
//  @State private var showNext = false
//  @State private var score: Int = 0
//  @State private var questionCount: Int = 0
//  @State private var isFlippedMode: Bool = false
//  @State private var timeRemaining: Int = 10
//  @State private var isFinished: Bool = false
//
//  let totalQuestions = 10
//  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//  var body: some View {
//    NavigationStack {
//      VStack(spacing: 20) {
//        if isFinished {
//          Text("Klaar!")
//            .font(.largeTitle)
//          Text("Je score: \(score) / \(totalQuestions)")
//            .font(.title2)
//            .foregroundColor(.blue)
//          Button("Opnieuw") {
//            restartQuiz()
//          }
//          .buttonStyle(CapsuleButtonStyle())
//          .padding()
//        } else {
//          quizBody
//        }
//      }
//      .padding()
//      .islandBackground()
//      .onAppear(perform: swapQuestion)
//      .onChange(of: isFlippedMode) {
//        updateOptionsForCurrentObs()
//      }
//      .onReceive(timer) { _ in
//        guard !showNext && !isFinished else { return }
//        if timeRemaining > 0 {
//          timeRemaining -= 1
//        } else {
//          feedback = correctAnswerText()
//          showNext = true
//          playSound(named: "wrong")
//        }
//      }
//    }
//  }
//
//  var quizBody: some View {
//    VStack(spacing: 16) {
//      VStack(spacing: 16) {
//        HStack(spacing: 20) {
//          Label("Vraag \(questionCount + 1)/\(totalQuestions)", systemImage: "questionmark.circle")
//            .font(.subheadline)
//          Label("Score: \(score)", systemImage: "checkmark.seal")
//            .font(.subheadline)
//        }
//
//        Text("\(timeRemaining)")
//          .font(.title)
//          .foregroundColor(.gray)
//      }
//      .padding()
//      .frame(maxWidth: .infinity)
//      .islandBackground()
//
//      Text(isFlippedMode ? currentSpeciesName.scientificName : currentSpeciesName.commonName)
//        .font(.largeTitle)
//        .fontWeight(.bold)
//        .multilineTextAlignment(.center)
//        .padding(.horizontal)
//
//      Spacer()
//
//      if showNext {
//        Button(action: loadQuestion) {
//          HStack {
//            Image(systemName: "arrow.right.circle.fill")
//            Text("Next")
//          }
//        }
//        .buttonStyle(CapsuleButtonStyle())
//      }
//
//      Spacer()
//
//      ForEach(options, id: \.id) { option in
//        let answerText = isFlippedMode ? option.commonName : option.scientificName
//
//        Button(action: {
//          checkAnswer(option)
//        }) {
//          Text(answerText)
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//              Group {
//                if showNext && option.id == currentSpeciesName.id {
//                  (feedback == "Correct!" ? Color.green : Color.red)
//                } else {
//                  Color.clear
//                }
//              }
//            )
//            .background(.thinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//            .overlay(
//              RoundedRectangle(cornerRadius: 12, style: .continuous)
//                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//            )
//            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
//        }
//        .disabled(showNext)
//        .foregroundColor(.primary)
//      }
//    }
//    .toolbar {
//      ToolbarItem(placement: .navigationBarTrailing) {
//        Button(action: {
//          isFlippedMode.toggle()
//        }) {
//          Image(systemName: isFlippedMode ? "checkmark.square" : "square")
//            .uniformSize()
//        }
//        .help("Wissel tussen wetenschappelijke en Nederlandse naam")
//      }
//
//      ToolbarItem(placement: .navigationBarTrailing) {
//        ShareLink(
//          item: String(localized: "aiChat") + " " + currentSpeciesName.scientificName
//        ) {
//          SVGImage(svg: "artificialintel")
//        }
//      }
//    }
//  }
//
//  func swapQuestion() {
//    feedback = ""
//    showNext = false
//    timeRemaining = 10
//
//    if questionCount >= totalQuestions {
//      isFinished = true
//      return
//    }
//
//    currentSpeciesName = speciesNames.randomElement() ?? SpeciesName(commonName: "", scientificName: "")
//    updateOptionsForCurrentObs()
//  }
//
//  func loadQuestion() {
//    feedback = ""
//    showNext = false
//    timeRemaining = 10
//    questionCount += 1
//
//    if questionCount >= totalQuestions {
//      isFinished = true
//      return
//    }
//
//    currentSpeciesName = speciesNames.randomElement() ?? SpeciesName(commonName: "", scientificName: "")
//    updateOptionsForCurrentObs()
//  }
//
//  func updateOptionsForCurrentObs() {
//    let correct = currentSpeciesName
//    let wrongOptions = speciesNames
//      .filter { $0.id != correct.id }
//      .shuffled()
//      .prefix(3)
//
//    options = (wrongOptions + [correct]).uniqued().shuffled()
//  }
//
//  func checkAnswer(_ selected: SpeciesName) {
//    let correct = isFlippedMode ? currentSpeciesName.commonName : currentSpeciesName.scientificName
//    let answer = isFlippedMode ? selected.commonName : selected.scientificName
//
//    if answer == correct {
//      feedback = "Correct!"
//      score += 1
//      playSound(named: "correct")
//    } else {
//      feedback = correct
//      playSound(named: "wrong")
//    }
//    showNext = true
//  }
//
//  func correctAnswerText() -> String {
//    isFlippedMode ? currentSpeciesName.commonName : currentSpeciesName.scientificName
//  }
//
//  func restartQuiz() {
//    score = 0
//    questionCount = 0
//    isFinished = false
//    loadQuestion()
//  }
//
//  func playSound(named soundName: String) {
//    guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
//      print("Sound file not found: \(soundName).wav")
//      return
//    }
//
//    var player: AVAudioPlayer?
//    player = try? AVAudioPlayer(contentsOf: url)
//    player?.play()
//  }
//}
