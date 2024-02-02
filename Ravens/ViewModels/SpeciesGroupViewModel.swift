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

    init() {
        fetchData(language: "eng")
    }

    func fetchData(language: String) {
        log.info("fetchData SpeciesGroupViewModel")
        let url = endPoint+"species-groups"

//         Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]

        // Use Alamofire to make the API request
        AF.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.speciesGroups = try decoder.decode([SpeciesGroup].self, from: response.data!)
                } catch {
                    self.log.error("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error fetching data: \(error)")
            }
        }
    }
}
