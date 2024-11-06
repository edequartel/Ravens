//
//  LocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

// get the LocationId from latitude and longitude
class LocationIdViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var locations: [LocationJSON] = []
    
    private var keyChainViewModel =  KeychainViewModel()

    func fetchLocations(latitude: Double, longitude: Double, completion: @escaping ([LocationJSON]) -> Void) {
        log.info("fetchLocations")
        
        keyChainViewModel.retrieveCredentials()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept": "application/json"
        ]
        
        let url = URL(string: "https://waarneming.nl/api/v1/locations/?lat=\(latitude)&lng=\(longitude)")!
        log.info(url)
        
        AF.request(url, headers: headers).responseDecodable(of: ApiResponse.self) { response in
            guard let responseData = response.value else { return }
            DispatchQueue.main.async {
                self.locations = responseData.results
                completion(self.locations)
            }
        }
    }
}
