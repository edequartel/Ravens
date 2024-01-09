//
//  RegionViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation
import Alamofire

class RegionViewModel: ObservableObject {
    @Published var regions = [Region]()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        let url = "https://waarneming.nl/api/v1/regions/"
        
        // Use Alamofire to make the API request
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.regions = try decoder.decode([Region].self, from: response.data!)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
}
