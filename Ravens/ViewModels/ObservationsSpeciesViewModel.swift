//
//  ObservationsSpeciesViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import Foundation
import Alamofire
//import Combine

class ObservationsSpeciesViewModel: ObservableObject {
    @Published var observationsSpecies: ObservationsSpecies?
    
    func fetchData(speciesId:Int, endDate: Date) {
        print("fetchData ObservationsSpeciesViewModel")
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl",
            "Authorization": "Token 21047b0d6742dc36234bc5293053bc757623470b" //<<TOKEN LATER BIJ ZETTEN 3600??
        ]
    
        let url = "https://waarneming.nl/api/v1/species/\(speciesId)/observations/?date_after=\(formatCurrentDate(value: endDate))"
        print("\(url)")

        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
//                print("Response as String: \(stringResponse)")

                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observationsSpecies = try decoder.decode(ObservationsSpecies.self, from: data)

                        DispatchQueue.main.async {
                            self.observationsSpecies = observationsSpecies
                            // Continue with your logic
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }

    }
}
