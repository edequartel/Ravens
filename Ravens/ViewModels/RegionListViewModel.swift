//
//  RegionViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class RegionListViewModel: ObservableObject { //<<change in region list not region
    let log = SwiftyBeaver.self
    @Published var regionLists = [RegionList]()

    init() {
        fetchData()
    }

    func fetchData() {
        log.info("fetchData RegionListViewModel")
        let url = endPoint+"region-lists"
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]

        // Use Alamofire to make the API request
        AF.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.regionLists = try decoder.decode([RegionList].self, from: response.data!)
                } catch {
                    self.log.error("Error RegionListViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error RegionListViewModel fetching data: \(error)")
            }
        }
    }
}
