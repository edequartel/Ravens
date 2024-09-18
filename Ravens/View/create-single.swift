//
//  create-single.swift
//  Ravens
//
//  Created by Eric de Quartel on 28/08/2024.
//

import SwiftUI
import Alamofire

// Define the data model for the observation
struct ObservationC: Encodable {
  var species: Int
  var point: String
  var number: Int
  var date: String
  var notes: String
}

// View Model to handle the network request
class ObservationXViewModel: ObservableObject {
  // Function to post observation
  func postObservation(
    number: Int,
    completion: @escaping (Bool, String) -> Void) {

      let url = "https://waarneming.nl/api/v1/observations/create-single/"

      let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Token 01d3455e878b6c4e6712c550ef460e17b9d2dc2d"  // Replace with your actual access token
      ]
      let observation = ObservationC(
        species: 58,
        point: "POINT(4 52)",
        number: number,
        date: "2024-08-28",
        notes: "This is a test observation")

      AF.request(url,
                 method: .post,
                 parameters: observation,
                 encoder: JSONParameterEncoder.default,
                 headers: headers).response { response in
        switch response.result {
        case .success:
          completion(true, "Observation posted successfully")
        case .failure(let error):
          completion(false, "Error posting observation: \(error.localizedDescription)")
        }
      }
    }
}

// SwiftUI View
struct CreateView: View {
  @ObservedObject var viewModel = ObservationXViewModel()
  @State private var message = ""
  @State private var isSuccessful = false

  @State private var number: String = "1"

  var body: some View {
    VStack {
      TextField("Enter number", text: $number) // Create a numeric TextField
        .keyboardType(.numberPad) // Make the keyboard only show numbers
      Button("Post Observation") {
        viewModel.postObservation(
          number: Int(number) ?? 0) { success, message in
            self.isSuccessful = success
            self.message = message
          }
      }
      Text(message)
        .foregroundColor(isSuccessful ? .green : .red)
        .padding()
    }
    .padding(10)
  }
}
