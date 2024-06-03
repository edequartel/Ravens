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
    
    func getId(region: Int, species_group: Int) -> Int {
        log.verbose("getID from regionListViewModel region: \(region) species_group: \(species_group)")
        if let matchingItem = regionLists.first(
            where: { $0.region == region && $0.species_group == species_group }) {
            log.verbose("getId= \(matchingItem.id)")
            return matchingItem.id
        }
        log.verbose("getId: not found")
        return -1
    }
    
    func fetchData(language: String, completion: (() -> Void)? = nil) {
        log.info("fetchData RegionListViewModel")
        let url = endPoint+"region-lists"
        
        log.info("RegionListViewModel url = \(url)")
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]

        // Use Alamofire to make the API request
        AF.request(url, headers: headers).responseDecodable(of: [RegionList].self)
        {   response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Species objects
                    let decoder = JSONDecoder()
                    self.regionLists = try decoder.decode([RegionList].self, from: response.data!)
                    completion?() // call the completion handler if it exists
                } catch {
                    self.log.error("Error RegionListViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error RegionListViewModel fetching data: \(error)")
            }
        }
    }
}
