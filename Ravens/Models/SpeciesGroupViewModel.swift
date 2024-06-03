//
//  SpeciesGroupViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver



class SpeciesGroupsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var speciesGroups = [SpeciesGroup]()
    @Published var speciesGroupsByRegion = [SpeciesGroup]() // workarray
    
    var speciesDictionary: [Int: String] = [:]
    
    func fetchData(language: String, completion: (() -> Void)? = nil) {
        log.info("fetchData SpeciesGroupViewModel \(language)")
        let url = endPoint + "species-groups"
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]
        
        log.info("url SpeciesGroupViewModel: \(url)")
        
        // Use Alamofire to make the API request
        AF.request(url, headers: headers)
            .responseDecodable(of: [SpeciesGroup].self)
        { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of SpeciesGroup objects
                    let decoder = JSONDecoder()
                    self.speciesGroups = try decoder.decode([SpeciesGroup].self, from: response.data!)
                    self.speciesGroupsByRegion = self.speciesGroups
                    
                    // Update the speciesDictionary
                    self.speciesDictionary = Dictionary(uniqueKeysWithValues: self.speciesGroups.map { ($0.id, $0.name) })
                    
                    // Call the completion handler when the data is successfully fetched
                    completion?() // call the completion handler if it exists
                } catch {
                    self.log.error("Error SpeciesGroupViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesGroupViewModel fetching data: \(error)")
//                completion(false)
            }
        }
    }
    
    // Function to get the name based on the id
    func getName(forID id: Int) -> String? {
        return speciesDictionary[id]
    }
}

