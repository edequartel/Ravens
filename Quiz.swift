//
//  Quiz.swift
//  Ravens
//
//  Created by Eric de Quartel on 01/08/2025.
//
import SwiftUI
import AVFoundation

struct BirdQuizView: View {
  @EnvironmentObject var observationUser: ObservationsViewModel

  @State private var currentObs: Obs = mockObservation
  @State private var options: [Obs] = []
  @State private var feedback: String = ""
  @State private var showNext = false
  @State private var score: Int = 0
  @State private var questionCount: Int = 0
  @State private var isFlippedMode: Bool = false
  @State private var timeRemaining: Int = 10
  @State private var isFinished: Bool = false

  let totalQuestions = 5
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        if isFinished {
          Text("Klaar!")
            .font(.largeTitle)
          Text("Je score: \(score) / \(totalQuestions-1)")
            .font(.title2)
            .foregroundColor(.blue)
          Button("Opnieuw") {
            restartQuiz()
          }
          .buttonStyle(CapsuleButtonStyle())
          .padding()
        } else {
          quizBody
        }
      }
      .padding()
      .islandBackground()
      .onAppear(perform: swapQuestion)
      .onChange(of: isFlippedMode) {
        updateOptionsForCurrentObs()
      }
      .onReceive(timer) { _ in
        guard !showNext && !isFinished else { return }
        if timeRemaining > 0 {
          timeRemaining -= 1
        } else {
          feedback = "\(correctAnswerText())"
          showNext = true
          playSound(named: "wrong")
        }
      }
    }

  }

  var quizBody: some View {
    VStack(spacing: 16) {
      VStack(spacing: 16) {
        HStack(spacing: 20) {
          Label("Vraag \(questionCount + 1)/\(totalQuestions)", systemImage: "questionmark.circle")
            .font(.subheadline)
          Label("Score: \(score)", systemImage: "checkmark.seal")
            .font(.subheadline)
        }

        Text("\(timeRemaining)")
          .font(.title)
          .foregroundColor(.gray)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .islandBackground()

      Text(isFlippedMode ? currentObs.speciesDetail.scientificName : currentObs.speciesDetail.name)
        .font(.largeTitle)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      Spacer()

      if showNext {
        Button(action: loadQuestion) {
          HStack {
            Image(systemName: "arrow.right.circle.fill")
            Text("Next")
          }
        }
        .buttonStyle(CapsuleButtonStyle())
      }

      Spacer()

      ForEach(options, id: \.id) { option in
        let answerText = isFlippedMode ? option.speciesDetail.name : option.speciesDetail.scientificName

        Button(action: {
          checkAnswer(option)
        }) {
          Text(answerText)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .background(
              showNext && option.id == currentObs.id
                ? (feedback == "Correct!" ? .green : .red)
                : Color.blue.opacity(0.2)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .disabled(showNext)
      }
    }
    
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          isFlippedMode.toggle()
        }) {
          Image(systemName: isFlippedMode ? "checkmark.square" : "square")
            .uniformSize()
        }
        .help("Wissel tussen wetenschappelijke en Nederlandse naam")
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        ShareLink(
          item: "Provide the etymology of the following species name in plain text, along with an optional fun fact. " + currentObs.speciesDetail.scientificName
        ) {
          SVGImage(svg: "artificialintel")
        }
        .help("Deel soortnaam voor etymologie")
      }

    }
  }

  func swapQuestion() {
    feedback = ""
    showNext = false

    if questionCount > totalQuestions {
      isFinished = true
      return
    }

    currentObs = observationUser.observations?.randomElement() ?? mockObservation
    updateOptionsForCurrentObs()
  }

  func loadQuestion() {
    feedback = ""
    showNext = false
    timeRemaining = 10
    questionCount += 1

    if questionCount > totalQuestions {
      isFinished = true
      return
    }

    currentObs = observationUser.observations?.randomElement() ?? mockObservation
    updateOptionsForCurrentObs()
  }

  func updateOptionsForCurrentObs() {
    let correct = currentObs
    let wrongOptions = observationUser.observations?
      .filter { $0 != currentObs }
      .shuffled()
      .prefix(3) ?? []

    options = (wrongOptions + [correct]).shuffled()
  }

  func checkAnswer(_ selected: Obs) {
    let correct = isFlippedMode ? currentObs.speciesDetail.name : currentObs.speciesDetail.scientificName
    let answer = isFlippedMode ? selected.speciesDetail.name : selected.speciesDetail.scientificName

    if answer == correct {
      feedback = "Correct!"
      score += 1
      playSound(named: "correct")
    } else {
      feedback = "\(correct)"
      playSound(named: "wrong")
    }
    showNext = true
  }

  func correctAnswerText() -> String {
    isFlippedMode ? currentObs.speciesDetail.name : currentObs.speciesDetail.scientificName
  }

  func restartQuiz() {
    score = 0
    questionCount = 0
    isFinished = false
    loadQuestion()
  }

  func playSound(named soundName: String) {
    guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
      print("Sound file not found: \(soundName).wav")
      return
    }

    var player: AVAudioPlayer?
    player = try? AVAudioPlayer(contentsOf: url)
    player?.play()
  }
}
