//
//  SpeciesViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//
// View Model for Species data

import Foundation
import Alamofire
import SwiftyBeaver
import SwiftSoup

class SpeciesViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  
  @Published var species = [Species]()
  @Published var speciesSecondLanguage = [Species]()
  
  @Published var errorMessage: String?
  
  var datum: String = ""

  // Helper function to convert date and time strings into a Date object
  private func convertToDate(dateString: String, timeString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // Adjust format as per your date-time strings
    return dateFormatter.date(from: "\(dateString) \(timeString)") ?? Date.distantPast
  }

  //??HIERO

  func fetchDataFirst(settings: Settings, completion: (() -> Void)? = nil) {
    log.info("\(settings.selectedSpeciesGroup ?? -1)")
    
    log.info("SpeciesViewModel fetchDataFirst \(settings.selectedLanguage) groupID \(settings.selectedRegionListId)")
    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"
    
    log.error("url: \(url)")

    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedLanguage
    ]
    
    AF.request(url, headers: headers).responseDecodable(of: [Species].self) { response in
      // Check if response data exists
      if let data = response.data {
        // Convert data to String and print
        let str = String(data: data, encoding: .utf8)
        self.log.verbose(str ?? "No data")
      }
      
      switch response.result {
      case .success:
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.species = try decoder.decode([Species].self, from: response.data!)
          completion?() // call the completion handler if it exists
          //          self.parseHTMLFromURL(settings: settings, completion: {print("parseHTMLFromURL done")})xxz
        } catch {
          self.log.error("Error 3 SpeciesViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error 4 SpeciesViewModel fetching data \(url) \(error)")
      }
    }
  }
  
  func fetchDataSecondLanguage(settings: Settings, completion: (() -> Void)? = nil) {
    log.error("SpeciesViewModel 5")
    log.error("SpeciesViewModel fetchDataSecondLanguage \(settings.selectedSecondLanguage) groupID \(settings.selectedRegionListId)")

    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"
    log.error("SpeciesViewModel 5 \(url)")

    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedSecondLanguage
    ]
    
    AF.request(url, headers: headers).responseDecodable(of: [Species].self) { response in
      // Check if response data exists
      if let data = response.data {
        // Convert data to String and print
        let str = String(data: data, encoding: .utf8)
        self.log.verbose(str ?? "No data")
      }
      
      switch response.result {
      case .success:
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.speciesSecondLanguage = try decoder.decode([Species].self, from: response.data!)
          completion?() // call the completion handler if it exists
        } catch {
          self.log.error("Error 1 SpeciesViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error 2 SpeciesViewModel fetching data \(url) \(error)")
      }
    }
  }

  func findSpeciesByScientificName(scientificName: String) -> Species? {
    return species.first { $0.scientificName == scientificName }
  }

  func findSpeciesIndexByScientificName(scientificName: String) -> Int? {
    return species.firstIndex { $0.scientificName == scientificName }
  }
  
  func findSpeciesByID(speciesID: Int) -> String? {
    guard let index = species.firstIndex(where: { $0.speciesId == speciesID }) else {
      return nil
    }
    
    // Check if index is within the range of speciesSecondLanguage array
    guard index < speciesSecondLanguage.count else {
      log.info("Index is out of range")
      return nil
    }
    
    return speciesSecondLanguage[index].name
  }

  // Function to sort species based on the selected sort option
  func sortedSpecies(by sortOption: SortNameOption) -> [Species] {
    switch sortOption {
    case .name:
      return species.sorted { $0.name < $1.name }
    case .scientificName:
      return species.sorted { $0.scientificName < $1.scientificName }
    }
  }
}
