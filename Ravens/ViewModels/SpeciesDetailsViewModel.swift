//
//  SpeciesDetailsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import Combine


import SwiftUI
import Alamofire

class SpeciesDetailsViewModel: ObservableObject {
    @Published var speciesDetails: SpeciesDetails?

    func fetchData(for speciesID: Int) {
        guard let url = URL(string: "https://waarneming.nl/api/v1/species/\(speciesID)/") else {
            return
        }
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]

        AF.request(url, headers: headers).responseDecodable(of: SpeciesDetails.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.speciesDetails = data
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
}
