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

class ObservationsViewModel: ObservableObject {
  let log = SwiftyBeaver.self

  @Published var observations: [Observation]?
//  @Published var observations: [Observation] = []

  @Published var limit = 0
  @Published var offset = 0
  @Published var count = 0
  @Published var next = ""
  @Published var previous = ""

  func fetchDataInit(settings: Settings, entity: EntityType, id: Int, completion: @escaping () -> Void) {
    log.error("fetchDataInit")
  }

  private var keyChainViewModel =  KeychainViewModel()

  func fetchData2(settings: Settings, url: String, completion: @escaping () -> Void) {
    log.info("fetchData2 ObservationsViewModel userId: \(url)")
    keyChainViewModel.retrieveCredentials()

    self.reset() //???


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
//              self.resObservations = observations.results
//              print(">> observations.count:\(observations.count ?? 0)")

              self.observations = (self.observations ?? []) + observations.results
              self.count = observations.count ?? 0

              self.getTimeData()

              self.next = observations.next?.absoluteString ?? ""
              self.previous = observations.previous?.absoluteString ?? ""

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


  func fetchData(settings: Settings, entity: EntityType, id: Int, completion: @escaping () -> Void) {
    log.info("fetchData ObservationsViewModel userId: \(id) limit: \(limit) offset: \(offset)")
    keyChainViewModel.retrieveCredentials()

//    if (entity == .area) { self.reset() } //@@@
    self.reset() //???


    //datetime
    let date: Date = Date.now
    let dateAfter = formatCurrentDate(
      value: Calendar.current.date(
        byAdding: .day,
        value: -14,
        to: date)!)
    let dateBefore = formatCurrentDate(value: date)
    log.error("date after \(dateAfter)")
    log.error("date before \(dateBefore)")


    // Add the custom header
    let headers: HTTPHeaders = [
      "Authorization": "Token "+keyChainViewModel.token,
      "Accept-Language": settings.selectedLanguage
    ]

    print(entity)
    var url = endPoint(value: settings.selectedInBetween) + "\(entity.rawValue)/\(id)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"

    url += "&date_after=\(dateAfter)&date_before=\(dateBefore)"

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
//              print(">> observations.count:\(observations.count ?? 0)")

              self.observations = (self.observations ?? []) + observations.results
              self.count = observations.count ?? 0

              self.getTimeData()

              self.next = observations.next?.absoluteString ?? ""
              self.previous = observations.previous?.absoluteString ?? ""

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



  func reset() {
//    limit = 0
//    offset = 0
//    self.observations = []
//    print("reset the limit and the observations")
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


//print(entity)
////    let url = endPoint(value: settings.selectedInBetween) + "species/785/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"
//var url = endPoint(value: settings.selectedInBetween) + "\(entity.rawValue)/\(id)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"
////    let url = endPoint(value: settings.selectedInBetween) + "locations/17861/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"
//
////    url += "&date_after=\(dateAfter)&date_before=\(dateBefore)"


//func fetchData(settings: Settings, entity: EntityType, id: Int, completion: @escaping () -> Void) {
//  log.info("fetchData ObservationsViewModel userId: \(id) limit: \(limit) offset: \(offset)")
//  keyChainViewModel.retrieveCredentials()
//
////    if (entity == .area) { self.reset() } //@@@
//  self.reset() //???
//
//
//  //datetime
//  let date: Date = Date.now
//  let dateAfter = formatCurrentDate(
//    value: Calendar.current.date(
//      byAdding: .day,
//      value: -14,
//      to: date)!)
//  let dateBefore = formatCurrentDate(value: date)
//  log.error("date after \(dateAfter)")
//  log.error("date before \(dateBefore)")
//
//
//  // Add the custom header
//  let headers: HTTPHeaders = [
//    "Authorization": "Token "+keyChainViewModel.token,
//    "Accept-Language": settings.selectedLanguage
//  ]
//
//  print(entity)
//  var url = endPoint(value: settings.selectedInBetween) + "\(entity.rawValue)/\(id)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)"
//
//  url += "&date_after=\(dateAfter)&date_before=\(dateBefore)"
//
//  log.error("fetchData ObservationsUserViewModel \(url)")
//
//  AF.request(url, headers: headers).responseString { response in
//    switch response.result {
//    case .success(let stringResponse):
//      // Now you can convert the stringResponse to Data and decode it
//      if let data = stringResponse.data(using: .utf8) {
//        do {
//          let decoder = JSONDecoder()
//          let observations = try decoder.decode(Observations.self, from: data)
//
//          DispatchQueue.main.async {
////              self.resObservations = observations.results
////              print(">> observations.count:\(observations.count ?? 0)")
//
//            self.observations = (self.observations ?? []) + observations.results
//            self.count = observations.count ?? 0
//
//            self.getTimeData()
//
//            self.next = observations.next?.absoluteString ?? ""
//            self.previous = observations.previous?.absoluteString ?? ""
//
//            let result = extractLimitAndOffset(from: observations.next?.absoluteString ?? "")
//            self.limit = result.limit ?? 100
//            self.offset = result.offset ?? 0
//
//            completion() // call the completion handler if it exists
//          }
//
//        } catch {
//          print("\(stringResponse)")
//          self.log.error("Error ObservationsUserViewModel decoding JSON: \(error)")
//          self.log.error("\(url)")
//        }
//      }
//    case .failure(let error):
//      self.log.error("Error ObservationsUserViewModel: \(error)")
//    }
//  }
//}

