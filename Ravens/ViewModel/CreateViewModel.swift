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
      "notes": note
    ]

    AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
      .validate()
      .responseDecodable(of: ObservationResponse.self) { response in
        switch response.result {
        case .success(let obs):
          DispatchQueue.main.async {
            self.observation = obs
            completion?()
          }
        case .failure(let error):
          self.log.error("Error in createObservation: \(error)")
        }
      }
  }
}

// ===

struct CreateObservationView: View {
  let log = SwiftyBeaver.self
  @StateObject private var viewModel = CreateViewModel()
  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var locationManager: LocationManagerModel

  var speciesID: Int
  var speciesName: String

  @State private var latitude: Double = 52.0
  @State private var longitude: Double = 4.0
  @State private var number: Int = 1
  @State private var date: Date = Date()
  @State private var time: Date = Date()
  @State private var note: String = "Verwijderen!"

  @State private var submitted = false

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Observation Details")) {
          Stepper(value: $number, in: 1...100) {
            Text("Aantal \(number)")
          }
          DatePicker("Date", selection: $date, displayedComponents: .date)
          DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
        }

        Section(header: Text("Note")) {
          TextField("", text: $note)
        }

        Section("pdf") {
          NavigationLink(destination: PdfView()) {
            Text("pdf")
          }
        }

        Button("Submit") {
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd"
          let formattedDate = formatter.string(from: date)
          let userLocation = locationManager.getCurrentLocation()
          let timeFormatter = DateFormatter()
          timeFormatter.dateFormat = "HH:mm"
          let formattedTime = timeFormatter.string(from: time)
          print("\(formattedDate) \(formattedTime)")

          viewModel.createObservation(
            token: keyChainViewModel.token,
            species: speciesID,
            longitude: userLocation?.coordinate.longitude ?? 52,
            latitude: userLocation?.coordinate.latitude ?? 0,
            number: number,
            date: formattedDate,
            time: formattedTime,
            note: note
          ) {
            submitted = true
          }
        }
        .disabled(keyChainViewModel.token.isEmpty)
      }
    }
    .navigationTitle("\(speciesName)")
  }
}

#Preview {
  CreateObservationView(speciesID: 150, speciesName: "Merel")
}
