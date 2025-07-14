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
      "notes": note,
      "accuracy": 5,
      
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

// ===

struct CreateObservationView: View {
  let log = SwiftyBeaver.self
  @StateObject private var viewModel = CreateViewModel()
  @EnvironmentObject var keyChainViewModel: KeychainViewModel
  @EnvironmentObject var locationManager: LocationManagerModel

  @EnvironmentObject var observationUser: ObservationsViewModel
  var allObservationNamesText: String {
    let header = "| naam \t\t date |\n|---|---|"
    let rows = (observationUser.observations ?? [])
      .compactMap {
        return "\($0.speciesDetail.name) \t\t \($0.date)"
      }
      .joined(separator: "\n")
    return "\(header)\n\(rows)"
  }

  @Environment(\.dismiss) private var dismiss  // iOS 15+

  var speciesID: Int
  var speciesName: String

  @State private var latitude: Double = 52.0
  @State private var longitude: Double = 4.0
  @State private var number: Int = 1
  @State private var date: Date = Date()
  @State private var time: Date = Date()
  @State private var note: String = ""

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

//        Section("pdf") {
//          NavigationLink(destination: PdfView()) {
//            Text("pdf")
//          }
//        }

        ShareLink(item: allObservationNamesText) {
          Label("Share Observations", systemImage: "square.and.arrow.up")
        }
        .padding()
//
//        Section("list") {
//          ScrollView {
//            Text(allObservationNamesText)
//              .padding()
//          }
//        }

        HStack {
          Spacer()
          Button(action: {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = formatter.string(from: date)
            let userLocation = locationManager.getCurrentLocation()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedTime = timeFormatter.string(from: time)

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
              log.error("dismissed")
              dismiss() // <-- Dismiss view after successful submission
            }
          }) {
            Text("Submit")
              .foregroundColor(.white)
              .padding()
              .background(Color.blue)
              .cornerRadius(8)
          }
          .disabled(keyChainViewModel.token.isEmpty)
          Spacer()
        }
      }
      .navigationTitle("\(speciesName)")
    }
  }
}

#Preview {
  CreateObservationView(speciesID: 150, speciesName: "Merel")
}
