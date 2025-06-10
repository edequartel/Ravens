//
//  RegionViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class RegionListViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  @Published var regionLists = [RegionList]()

  var entryDict: [Int: Int] = [:]

  func fetchData(settings: Settings, completion: (() -> Void)? = nil) {
    log.error("fetchData RegionListViewModel")
    let url = endPoint(value: settings.selectedInBetween)+"region-lists"

    log.info("RegionListViewModel url = \(url)")

    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedLanguage
    ]

    // Use Alamofire to make the API request
    AF.request(url, headers: headers).responseDecodable(of: [RegionList].self) {   response in
      switch response.result {
      case .success:
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.regionLists = try decoder.decode([RegionList].self, from: response.data!)

          //!!
          self.entryDict = Dictionary(uniqueKeysWithValues: self.regionLists.map {
            ($0.region * 100 + $0.speciesGroup, $0.id)
          })
          //!!

          completion?() // call the completion handler if it exists
        } catch {
          self.log.error("Error RegionListViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error RegionListViewModel fetching data: \(error)")
      }
    }
  }

  // Function to get ID by region and speciesGroup
  func getId(region: Int, speciesGroup: Int) -> Int? {
    let key = region * 100 + speciesGroup
    return entryDict[key]
  }

}
