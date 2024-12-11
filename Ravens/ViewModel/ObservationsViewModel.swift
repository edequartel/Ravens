//
//  ObservationsViewModel.swift
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

enum EntityType: String {
  case area = "locations"
  case user = "user"
  case species = "species"

  // Computed property to return an associated integer value
  var days: Int {
    switch self {
    case .area:
      return 28
    case .user:
      return 28
    case .species:
      return 28
    }
  }
}

class ObservationsViewModel: ObservableObject {
  let log = SwiftyBeaver.self

  @Published var observations: [Observation]?

  private var limit = 100
  private var offset = 0

  @Published var count = 0
  @Published var next = ""
  @Published var previous = ""

  private var keyChainViewModel =  KeychainViewModel()

//  func PreviousFourteenDays(to date: Date) -> Date {
//    let daysToAdd = 14
//    return Calendar.current.date(byAdding: .day, value: -daysToAdd, to: date) ?? date
//  }

  func fetchDataInit(settings: Settings, entity: EntityType, id: Int, completion: @escaping () -> Void) {
    log.error("FetchDataInit")
    //reset
    self.observations = []

    //datetime
    let date: Date = Date.now
    let dateAfter = formatCurrentDate(value: Calendar.current.date(byAdding: .day,value: -entity.days, to: date)!)
    let dateBefore = formatCurrentDate(value: date)
    //add the periode to the url
    var url = endPoint(value: settings.selectedInBetween) + "\(entity.rawValue)/\(id)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"
    url += "&date_after=\(dateAfter)&date_before=\(dateBefore)" //hasPhoto
    url += "&has_photo=true"
    url += "&ordering=datetime"

    fetchData(settings: settings, url: url, completion: completion)
  }


  func fetchData(settings: Settings, url: String, completion: @escaping () -> Void) {
    print("fetchData url: [\(url)]")
    if url.isEmpty { return }
    //
    log.info("fetchData ObservationsViewModel userId: \(url)")
    keyChainViewModel.retrieveCredentials()


    // Add the custom header
    let headers: HTTPHeaders = [
      "Authorization": "Token "+keyChainViewModel.token,
      "Accept-Language": settings.selectedLanguage
    ]

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
              self.observations = (self.observations ?? []) + observations.results
              //              self.observations = observations.results
              self.count = observations.count ?? 0

              self.getTimeData()

              self.next = observations.next?.absoluteString ?? ""
              self.previous = observations.previous?.absoluteString ?? ""

              print("prv: \(self.previous)")
              print("nxt: \(self.next)")

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

  //to make sorting easier, get the datetime in a seperate field
  func getTimeData() {
    let max = (observations?.count ?? 0)
    for index in 0..<max {
      //      print("data and time")
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

}
