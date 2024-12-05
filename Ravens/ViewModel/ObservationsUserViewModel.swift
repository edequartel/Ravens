//
//  ObservationsUserViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver
import SwiftUI
import SVGView

class ObservationsViewModel: ObservableObject {
  let log = SwiftyBeaver.self

  @Published var observations: [Observation]?
  @Published var limit = 0
  @Published var offset = 0

  private var keyChainViewModel =  KeychainViewModel()
  var locations = [Location]()

  func getLocations() {
    locations.removeAll() //@@@
    let max = (observations?.count ?? 0)
    for index in 0 ..< max {
      let name = observations?[index].speciesDetail.name ?? "Unknown name"
      let latitude = observations?[index].point.coordinates[1] ?? 52.024052
      let longitude = observations?[index].point.coordinates[0] ?? 5.245350
      let rarity = observations?[index].rarity ?? 0
      let hasPhoto = (observations?[index].photos?.count ?? 0 > 0)
      let hasSound = (observations?[index].sounds?.count ?? 0 > 0)
      let newLocation = Location(
        name: name,
        coordinate: CLLocationCoordinate2D(
          latitude: latitude,
          longitude: longitude),
        rarity: rarity,
        hasPhoto: hasPhoto,
        hasSound: hasSound)
      locations.append(newLocation)
    }
  }

  func getTimeData() {
    let max = (observations?.count ?? 0)
    for index in 0..<max {
      if let date = observations?[index].date,
         let time = observations?[index].time {

        // Concatenate date and time strings
        let timeDateStr = date + " " + time

        // Date formatter to parse the concatenated date and time string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        // Convert the concatenated string back to a Date
        if let formattedDate = dateFormatter.date(from: timeDateStr) {
          observations?[index].timeDate = formattedDate
        } else {
          // Handle error if the date string could not be parsed
          print("Error: Could not parse date string \(timeDateStr)")
        }
      } else {
        // Handle the case where either the date or time is nil
        log.info("Error: Missing date or time for index \(index)")
      }
    }
  }


  func fetchData(settings: Settings, entity: EntityType , id: Int, completion: @escaping () -> Void) {
    log.info("fetchData ObservationsUserViewModel userId: \(id) limit: \(limit) offset: \(offset)")
    keyChainViewModel.retrieveCredentials()

    // Add the custom header
    let headers: HTTPHeaders = [
      "Authorization": "Token "+keyChainViewModel.token,
      "Accept-Language": settings.selectedLanguage
    ]

    print(entity)
    let url = endPoint(value: settings.selectedInBetween) + "\(entity.rawValue)/\(id)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"
//    let url = endPoint(value: settings.selectedInBetween) + "user/\(userId)/observations/"+"?limit=\(self.limit)&offset=1600" //\(self.offset)"

    log.error("fetchData ObservationsUserViewModel \(url)")

    AF.request(url, headers: headers).responseString { response in
      switch response.result {
      case .success(let stringResponse):
        // Now you can convert the stringResponse to Data and decode it
        if let data = stringResponse.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let observations = try decoder.decode(Observations.self, from: data)

            DispatchQueue.main.async {
//              self.resObservations = observations.results
              print(">> observations:\(observations.count ?? 0)")
              self.observations = (self.observations ?? []) + observations.results

              self.getTimeData()
              self.getLocations()
              let result = extractLimitAndOffset(from: observations.next?.absoluteString ?? "")
              self.limit = result.limit ?? 100
              self.offset = result.offset ?? 0
              completion() // call the completion handler if it exists
            }

          } catch {
            print("\(stringResponse)")
            self.log.error("Error ObservationsUserViewModel decoding JSON: \(error)")
            self.log.error("\(url)")
          }
        }
      case .failure(let error):
        self.log.error("Error ObservationsUserViewModel: \(error)")
      }
    }
  }


  func reset() {
    limit = 0
    offset = 0
    observations = []
    locations = []
  }
}




func extractLimitAndOffset(from url: String) -> (limit: Int?, offset: Int?) {
    // Regular expression to match 'limit' and 'offset'
    let pattern = #"[\?&]limit=(\d+)&offset=(\d+)"#

    do {
        let regex = try NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(url.startIndex..<url.endIndex, in: url)

        if let match = regex.firstMatch(in: url, options: [], range: nsRange) {
            // Extracting 'limit' and 'offset' from the capture groups
            let limitRange = Range(match.range(at: 1), in: url)
            let offsetRange = Range(match.range(at: 2), in: url)

            let limit = limitRange.flatMap { Int(url[$0]) }
            let offset = offsetRange.flatMap { Int(url[$0]) }

            return (limit, offset)
        }
    } catch {
        print("Invalid regular expression: \(error)")
    }

    return (nil, nil)
}
