//
//  RegionViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

//header

import Foundation
import Alamofire
import SwiftyBeaver

class RegionViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var regions = [Region]()
    
    var settings: Settings
    init(settings: Settings) {
        log.info("init RegionViewModel")
        self.settings = settings
        fetchData()
    }


    func fetchData() {
        log.info("fetchData RegionViewModel")
        let url = settings.endPoint() + "regions/"

        log.info("url = \(url)")

        // Add the custom header 'Accept-Language: nl' eng, nl, de, fr
        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]

        // Create a URLRequest with caching policy and set the custom headers
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.cachePolicy = .returnCacheDataElseLoad // Use cached data if available, otherwise fetch from the network
        urlRequest.headers = headers // Set the custom headers

        // Use Alamofire to make the API request with the configured URLRequest
        AF.request(urlRequest).responseJSON { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Region objects
                    let decoder = JSONDecoder()
                    self.regions = try decoder.decode([Region].self, from: response.data!)
                } catch {
                    self.log.error("Error RegionViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error RegionViewModel fetching data: \(error)")
            }
        }
    }
}
