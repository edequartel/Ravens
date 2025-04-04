//
//  RadiusViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 21/01/2025.
//

import SwiftUI
import Alamofire
import MapKit
import SwiftyBeaver

// MARK: - ViewModel
class ObservationsRadiusViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  @Published var observations: [Observation]?
  @Published var errorMessage: String?
  @Published var hasLoadedData = false

  @Published var circleCenter = CLLocationCoordinate2D(latitude: 54.0, longitude: 6.0)

  @Published var count = 0
  @Published var next = ""
  @Published var previous = ""

  func fetchDataInit(
    settings: Settings,
    latitude: Double,
    longitude: Double,
    radius: Int,
    timePeriod: TimePeriod?,
    completion: @escaping () -> Void) {
      observations = []
      var url = "https://waarnemingen.nl/api/v1/observations/around-point/?"
      let date = Date()
      let dateFormatted = formatDate(date: date)
      if let days = timePeriod?.rawValue {
          url += "days=\(days)&"
      }
      url += "&end_date="+dateFormatted
      url += "&lat="+String(latitude)
      url += "&lng="+String(longitude)
      url += "&radius="+String(radius)

      self.log.error("url:\(url)")

      fetchData(
        settings: settings,
        url: url,
        completion: completion)
    }

  func fetchData(
    settings: Settings,
    url: String,
    completion: @escaping () -> Void) {
      log.info("ObservationsRadiusViewModel fetchData url: [\(url)]")
      if url.isEmpty { return }

      let headers: HTTPHeaders = [
        "Accept-Language": settings.selectedLanguage
      ]

      AF.request(url, headers: headers).responseString { response in
        switch response.result {
        case .success(let stringResponse):
          // Now you can convert the stringResponse to Data and decode it
          if let data = stringResponse.data(using: .utf8) {
            do {
              let decoder = JSONDecoder()
              let observations = try decoder.decode(Observations.self, from: data)

              DispatchQueue.main.async {
                self.observations = (self.observations ?? []) + (observations.results ?? [])

                self.count = observations.count ?? 0
                self.next = observations.next?.absoluteString ?? ""
                self.previous = observations.previous?.absoluteString ?? ""

                self.log.error("radius cont: \(self.count)")
                self.log.info("next: \(self.next)")
                self.log.info("prev: \(self.previous)")

                completion() // call the completion handler if it exists
              }

            } catch {
              self.log.error("\(stringResponse)")
            }
          }
        case .failure(let error):
          self.log.error("Error ObservationsUserViewModel: \(error)")
        }
      }
    }
}
