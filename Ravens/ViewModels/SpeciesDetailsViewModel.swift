//
//  SpeciesDetailsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import Combine
import SwiftyBeaver

class SpeciesDetailsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var speciesDetails: SpeciesDetails?

    func fetchData(for speciesID: Int) {
        guard let url = URL(string: "https://waarneming.nl/api/v1/species/\(speciesID)/") else {
            return
        }
        log.verbose("SpeciesDetailsViewModel speciesID: \(speciesID)")
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]
        log.verbose("SpeciesDetailsViewModel url: \(url)")
        
        AF.request(url, headers: headers).responseDecodable(of: SpeciesDetails.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
//                    self.log.verbose("succes in SpeciesDetailsViewModel \(data)")
                    self.speciesDetails = data
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
}
