//
//  SpeciesGroupViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class SpeciesGroupViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
    @Published var speciesGroups = [SpeciesGroup]()
    var speciesDictionary: [Int: String] = [:]

    init() {
        fetchData(language: "nl")
    }

    func fetchData(language: String) {
        log.info("fetchData SpeciesGroupViewModel \(language)")
        let url = endPoint + "species-groups"

        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]
        
        log.info("url SpeciesGroupViewModel: \(url)")

        // Use Alamofire to make the API request
        AF.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of SpeciesGroup objects
                    let decoder = JSONDecoder()
                    self.speciesGroups = try decoder.decode([SpeciesGroup].self, from: response.data!)

                    // Update the speciesDictionary
                    self.speciesDictionary = Dictionary(uniqueKeysWithValues: self.speciesGroups.map { ($0.id, $0.name) })
                    
                } catch {
                    self.log.error("Error SpeciesGroupViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesGroupViewModel fetching data: \(error)")
            }
        }
    }

    // Function to get the name based on the id
    func getName(forID id: Int) -> String? {
        return speciesDictionary[id]
    }
}


//class SpeciesGroupViewModel: ObservableObject {
//    let log = SwiftyBeaver.self
//    
//    @Published var speciesGroups = [SpeciesGroup]()
//    
//
//    init() {
//        fetchData(language: "nl")
//    }
//
//    func fetchData(language: String) {
//        log.info("fetchData SpeciesGroupViewModel")
//        let url = endPoint+"species-groups"
//
////         Add the custom header 'Accept-Language: nl'
//        let headers: HTTPHeaders = [
//            "Accept-Language": language
//        ]
//        
//        log.info("url SpeciesGroupViewModel: \(url)")
//
//        // Use Alamofire to make the API request
//        AF.request(url, headers: headers).responseJSON { response in
//            switch response.result {
//            case .success(_):
//                do {
//                    // Decode the JSON response into an array of Bird objects
//                    let decoder = JSONDecoder()
//                    self.speciesGroups = try decoder.decode([SpeciesGroup].self, from: response.data!)
//                } catch {
//                    self.log.error("Error SpeciesGroupViewModel decoding JSON: \(error)")
//                }
//            case .failure(let error):
//                self.log.error("Error SpeciesGroupViewModel fetching data: \(error)")
//            }
//        }
//    }
//}
