////
////  ObservationsYearViewModel.swift
////  Ravens
////
////  Created by Eric de Quartel on 18/01/2024.
////
//
//import Foundation
//import Alamofire
//import MapKit
//import SwiftyBeaver
//
//class ObservationsYearViewModel: ObservableObject {
//  let log = SwiftyBeaver.self
//  @Published var observationsSpecies: Observations?
//  @Published var months: [Int] = [0,0,0, 0,0,0, 0,0,0, 0,0,0]
//  private var maanden: [Int] = [0,0,0, 0,0,0, 0,0,0, 0,0,0]
//
//  private var keyChainViewModel =  KeychainViewModel()
//
//
//  func fetchMonthData(language: String, speciesId: Int) {
//    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let folderURL = documentsURL.appendingPathComponent("countObservations")
//    var count = 0
//
//    log.info(folderURL)
//    let fileURL = folderURL.appendingPathComponent("\(speciesId).json")
//
//    //        if false {
//    if FileManager.default.fileExists(atPath: fileURL.path) {
//      do {
//        log.info("filexists")
//        let jsonData = try Data(contentsOf: fileURL)
//        if let dataDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
//          log.info("Loaded data from file: \(dataDict)")
//          if let loadedMonths = dataDict["months"] as? [Int] {
//            self.months = loadedMonths
//          } else {
//            log.info("Failed to decode months array from JSON data.")
//          }
//        } else {
//          log.info("Failed to decode JSON data.")
//        }
//      } catch {
//        log.info("Failed to load data from file: \(error)")
//      }
//    } else {
//      log.info("file does not exists")
//
//
//      for month in 1...12 {
//        let monthString = String(format: "%02d", month)
//        let daystring = String(format: "%02d", numberOfDaysInMonth(year: 2023, month: month) ?? 0)
//        print("\(month) \(daystring)")
//        fetchData(
//          language: language,
//          speciesId: speciesId,
//          dateAfter: "2023-\(monthString)-01",
//          dateBefore: "2023-\(monthString)-\(daystring)") { (value) in
//            count += 1
//            self.log.info("count \(count)")
//            self.log.info("\(monthString) : value: \(value)")
//            self.maanden[month-1] = (value) // deze waarde later meenemen
//
//            if count == 12 {
//              self.months = self.maanden
//
//              let dataDict: [String: Any] = [
//                "months": self.months,
//                "date_after": "2023-\(monthString)-01",
//                "date_before": "2023-\(monthString)-28"
//              ]
//
//              guard let jsonData = try? JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted) else {
//                self.log.info("Failed to create JSON data.")
//                return
//              }
//
//              do {
//                if !FileManager.default.fileExists(atPath: folderURL.path) {
//                  try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
//                }
//              } catch {
//                self.log.info("Failed to create directory: \(error.localizedDescription)")
//              }
//
//              do {
//                try jsonData.write(to: fileURL)
//                self.log.info("Successfully saved data to \(fileURL)")
//              } catch {
//                self.log.error("Failed to write JSON data: \(error.localizedDescription)")
//              }
//
//
//              //                        self.maanden[m-1] = (value) //deze waarde later meenemen
//
//            }
//          }
//      }
//    }
//  }
//
//  func numberOfDaysInMonth(year: Int, month: Int) -> Int? {
//    let calendar = Calendar.current
//    let components = DateComponents(year: year, month: month)
//
//    guard let date = calendar.date(from: components),
//          let range = calendar.range(of: .day, in: .month, for: date) else {
//      return nil
//    }
//
//    return range.count
//  }
//
//  func deleteFilesInFolder() {
//    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let folderURL = documentsURL.appendingPathComponent("countObservations")
//
//    let fileManager = FileManager.default
//    do {
//      let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//      for fileURL in fileURLs {
//        try fileManager.removeItem(at: fileURL)
//      }
//    } catch {
//      // Handle the error
//      print("Error while deleting files: \(error)")
//    }
//  }
//
//  func fetchData(language: String, speciesId: Int, dateAfter: String, dateBefore: String, completion: @escaping (Int) -> Void) {
//    log.info("fetchData ObservationsYearViewModel - speciesID \(speciesId)")
//    keyChainViewModel.retrieveCredentials()
//
//    // Add the custom header
//    let headers: HTTPHeaders = [
//      "Authorization": "Token "+keyChainViewModel.token,
//      "Accept-Language": language
//    ]
//
//    // Define constants for the endpoint, paths, and query parameters
//    let baseEndpoint = endPoint()
//    let path = "species/\(speciesId)/observations/"
//    let dateAfterParam = "date_after=\(dateAfter)"
//    let dateBeforeParam = "date_before=\(dateBefore)"
//    let limitParam = "limit=100"
//    let offsetParam = "offset=0"
//
//    // Construct the full URL by combining all parts
//    let url = "\(baseEndpoint)\(path)?\(dateAfterParam)&\(dateBeforeParam)&\(limitParam)&\(offsetParam)"
//
//
//    log.info("url \(url)")
//
//    AF.request(url, headers: headers).responseString { response in
//      switch response.result {
//      case .success(let stringResponse):
//        if let data = stringResponse.data(using: .utf8) {
//          do {
//            let decoder = JSONDecoder()
//            let observationsSpecies = try decoder.decode(Observations.self, from: data)
//            DispatchQueue.main.async {
//              let value = observationsSpecies.count ?? 0
//              completion(value)
//            }
//          } catch {
//            self.log.error("Error ObservationsYearViewModel decoding JSON: \(error)")
//            //                        self.log.error("\(url)")
//          }
//        }
//      case .failure(let error):
//        self.log.error("Error ObservationsYearViewModel: \(error)")
//      }
//    }
//  }
//}
