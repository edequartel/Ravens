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
  @Published var errorMessage: String? = nil
  @Published var hasLoadedData = false
  
  @Published var circleCenter = CLLocationCoordinate2D(latitude: 54.0, longitude: 6.0)
  
  func fetchData(settings: Settings, latitude: Double, longitude: Double, radius: Double,timePeriod: TimePeriod, completion: (() -> Void)? = nil) {

    let url = "https://waarnemingen.be/api/v1/observations/around-point/"
    let date = Date()
    let dateFormatted = formatDate(date: date)
    let parameters: [String: Any] = [
      "days": timePeriod.rawValue,
      "end_date": dateFormatted,
      "species_group": settings.selectedSpeciesGroup,
      "radius": radius,
      "lat": latitude,
      "lng": longitude
    ]
    
    log.error("Fetching data from: \(url) +\(parameters)")

    AF.request(url, parameters: parameters).responseString { response in
      switch response.result {
      case .success(let stringResponse):
        // Now you can convert the stringResponse to Data and decode it
        if let data = stringResponse.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let observations = try decoder.decode(Observations.self, from: data)
            
            DispatchQueue.main.async {
              self.observations = (self.observations ?? []) + (observations.results ?? [])
              completion?() // call the completion handler if it exists
            }
            
          } catch {
            print("\(stringResponse)")
          }
        }
      case .failure(let error):
        print("Error ObservationsUserViewModel: \(error)")
      }
    }
  }
}

func formatDate(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter.string(from: date)
}
