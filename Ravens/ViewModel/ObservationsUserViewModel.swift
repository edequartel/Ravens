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

class Window: ObservableObject {
  @Published var maximum = 123
  @Published var offset = 15
  @Published var value = 0

  func next() {
    if value + offset > maximum {
      value = maximum
    } else {
      value += offset
    }
  }

  func previous() {
    let remainder = value % offset
    if remainder != 0 {
      value -= remainder
    } else if value - offset < 0 {
      value = 0
    } else {
      value -= offset
    }
  }
}

struct WindowView: View {
  @ObservedObject var windowObject = Window()

  var body: some View {
    VStack {
      Text("Value: \(windowObject.value)")
      ZStack {
        SVGView(contentsOf: Bundle.main.url(forResource: "plus-square", withExtension: "svg")!)
          .frame(width: 16, height: 16, alignment: .bottomTrailing)
          .foregroundColor(.green)

        SVGView(contentsOf: Bundle.main.url(forResource: "w_wikipedia", withExtension: "svg")!)
          .frame(width: 64, height: 64, alignment: .center)
          .foregroundColor(.green)
      }

      Button(action: {
        self.windowObject.next()
      }) {
        Text("Next")
      }

      Button(action: {
        self.windowObject.previous()
      }) {
        Text("Previous")
      }
    }
  }
}

class ObservationsViewModel: ObservableObject {
  let log = SwiftyBeaver.self

  @Published var observations: Observations?
  @Published var limit = 100
  @Published var offset = 0
  @Published var maxOffset = 200
  @Published var start = 0
  @Published var end = 100

  private var keyChainViewModel =  KeychainViewModel()
  var locations = [Location]()

  func getLocations() {
    locations.removeAll()
    let max = (observations?.results.count ?? 0)
    for index in 0 ..< max {
      let name = observations?.results[index].speciesDetail.name ?? "Unknown name"
      let latitude = observations?.results[index].point.coordinates[1] ?? 52.024052
      let longitude = observations?.results[index].point.coordinates[0] ?? 5.245350
      let rarity = observations?.results[index].rarity ?? 0
      let hasPhoto = (observations?.results[index].photos?.count ?? 0 > 0)
      let hasSound = (observations?.results[index].sounds?.count ?? 0 > 0)
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
    let max = (observations?.results.count ?? 0)
    for index in 0..<max {
      if let date = observations?.results[index].date,
         let time = observations?.results[index].time {

        // Concatenate date and time strings
        let timeDateStr = date + " " + time

        // Date formatter to parse the concatenated date and time string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        // Convert the concatenated string back to a Date
        if let formattedDate = dateFormatter.date(from: timeDateStr) {
          observations?.results[index].timeDate = formattedDate
        } else {
          // Handle error if the date string could not be parsed
          print("Error: Could not parse date string \(timeDateStr)")
        }
      } else {
        // Handle the case where either the date or time is nil
        print("Error: Missing date or time for index \(index)")
      }
    }
  }


  func fetchData(settings: Settings, entityType: String, userId: Int, completion: @escaping () -> Void) {
    log.info("fetchData ObservationsUserViewModel userId: \(userId) limit: \(limit) offset: \(offset)")
    keyChainViewModel.retrieveCredentials()

    // Add the custom header
    let headers: HTTPHeaders = [
      "Authorization": "Token "+keyChainViewModel.token,
      "Accept-Language": settings.selectedLanguage
    ]

    print(entityType)
    let url = endPoint(value: settings.selectedInBetween) + "user/\(userId)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"

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
              self.observations = observations
              self.getLocations()
              self.getTimeData() //??

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
}

