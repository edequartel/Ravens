//
//  CreateViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 10/07/2025.
//

import SwiftUI
import Alamofire
import MapKit
import SwiftyBeaver

struct ObservationResponse: Decodable {
  let id: Int
  let species: Int
  let date: String
  let time: String?
  let number: Int
  let sex: String
  let point: Point
  let accuracy: Int
  let notes: String?
  let isCertain: Bool
  let validationStatus: String
  let externalReference: String?
  let user: Int
  let modified: String
  let photos: [String]
  let permalink: String

  enum CodingKeys: String, CodingKey {
    case id, species, date, time, number, sex, point, accuracy, notes
    case isCertain = "is_certain"
    case validationStatus = "validation_status"
    case externalReference = "external_reference"
    case user, modified, photos, permalink
  }
}

class CreateViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  @Published var observation: ObservationResponse?

  func createObservation(token: String,
                         species: Int = 150,
                         longitude: Double = 4.0,
                         latitude: Double = 52.0,
                         number: Int = 3,
                         date: String = "2025-07-11",
                         time: String = "12:00",
                         note: String = "verwijderen!",
                         accuracy: Int = 5,
                         completion: (() -> Void)? = nil) {

    log.error("POST createObservation CreateViewModel \(time)")

    let url = "https://waarneming.nl/api/v1/observations/create-single/"

    let headers: HTTPHeaders = [
      "Authorization": "Token " + token
    ]

    let parameters: [String: Any] = [
      "species": species,
      "point": "POINT(\(longitude) \(latitude))",
      "number": number,
      "date": date,
      "time": time,
      "notes": note,
      "accuracy": accuracy
    ]

    AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
      .validate()
      .responseDecodable(of: ObservationResponse.self) { response in
        switch response.result {
        case .success:
          completion?()
        case .failure(let error):
          self.log.error("Error in createObservation: \(error)")
          completion?()  // still dismiss even if failed
        }
      }
  }
}

struct CreateObservationView: View {
  let log = SwiftyBeaver.self

  @StateObject private var viewModel = CreateViewModel()
  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var locationManager: LocationManagerModel
  @Environment(\.dismiss) private var dismiss

  var speciesID: Int
  var speciesName: String

  @State private var latitude: Double = 52.0
  @State private var longitude: Double = 4.0
  @State private var number: Int = 1
  @State private var date: Date = Date()
  @State private var time: Date = Date()
  @State private var note: String = ""

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text(observations)) {
          Stepper(value: $number, in: 1...100) {
            LabeledContent(nrof, value: "\(number)")
          }

          DatePicker(dateName, selection: $date, displayedComponents: .date)
            .datePickerStyle(.compact)

          DatePicker(timeName, selection: $time, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
        }

        Section(header: Text(note)) {
          TextEditor(text: $note)
            .frame(height: 100)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
        }

        Section {
          Button(action: handleSubmit) {
            Text(submit)
              .fontWeight(.bold)
              .frame(maxWidth: .infinity)
              .padding()
              .background(keyChainViewModel.token.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
              .foregroundColor(.white)
              .cornerRadius(12)
              .shadow(radius: 3)
          }
          .disabled(keyChainViewModel.token.isEmpty)
//          .buttonStyle(CapsuleButtonStyle())
        }
      }
      .navigationTitle(speciesName)
    }
  }

  private func handleSubmit() {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let formattedDate = formatter.string(from: date)

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    let formattedTime = timeFormatter.string(from: time)

    let userLocation = locationManager.getCurrentLocation()

    viewModel.createObservation(
      token: keyChainViewModel.token,
      species: speciesID,
      longitude: userLocation?.coordinate.longitude ?? 52,
      latitude: userLocation?.coordinate.latitude ?? 0,
      number: number,
      date: formattedDate,
      time: formattedTime,
      note: note,
      accuracy: locationManager.getCurrentAccuracy() ?? 999
    ) {
      log.error("dismissed")
      dismiss()
    }
  }
}

#Preview {
  CreateObservationView(speciesID: 150, speciesName: "Merel")
}
