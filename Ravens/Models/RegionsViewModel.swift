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

class RegionsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var regions = [Region]()
    
    func fetchData(language: String, completion: (() -> Void)? = nil) {
        log.info("fetchData RegionViewModel \(language)")
        let url = endPoint() + "regions/"

        log.info("url RegionViewModel \(url)")

        // Add the custom header 'Accept-Language: nl' eng, nl, de, fr
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]

        // Create a URLRequest with caching policy and set the custom headers
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.cachePolicy = .returnCacheDataElseLoad // Use cached data if available, otherwise fetch from the network
        urlRequest.headers = headers // Set the custom headers

        // Use Alamofire to make the API request with the configured URLRequest
        AF.request(url, headers: headers).responseDecodable(of: [Region].self)
        { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Region objects
                    let decoder = JSONDecoder()
                    self.regions = try decoder.decode([Region].self, from: response.data!)
                    completion?() // call the completion handler if it exists
                } catch {
                    self.log.error("Error RegionViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error RegionViewModel fetching data: \(error)")
            }
        }
    }
}