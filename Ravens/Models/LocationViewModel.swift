//
//  LocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import Foundation
import Alamofire

class LocationViewModel: ObservableObject {
    @Published var locations: [LocationJSON] = []
    @Published var isLoading: Bool = false

    func fetchLocations(latitude: Double, longitude: Double, completion: @escaping ([LocationJSON]) -> Void) {
        isLoading = true
        
        let headers: HTTPHeaders = [
            "Authorization": "Token 01d3455e878b6c4e6712c550ef460e17b9d2dc2d",
            "Accept": "application/json"
        ]
        
        let url = URL(string: "https://waarneming.nl/api/v1/locations/?lat=\(latitude)&lng=\(longitude)")!
        print(url)
        
        AF.request(url, headers: headers).responseDecodable(of: ApiResponse.self) { response in
            guard let responseData = response.value else { return }
            DispatchQueue.main.async {
                self.locations = responseData.results
                completion(self.locations)
                self.isLoading = false
            }
        }
    }
}
