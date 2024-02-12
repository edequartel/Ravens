//
//  SpeciesDetailsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class SpeciesDetailsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var speciesDetails: SpeciesDetails?
    
    init() {
        print("init SpeciesDetailsViewModel")
//        fetchData(for: 5001, language: "nl")
    }

    func fetchData(for speciesID: Int, language: String) {
        guard let url = URL(string: endPoint+"species/\(speciesID)/") else {
            return
        }
        log.info("SpeciesDetailsViewModel speciesID: \(speciesID)")
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
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
                self.log.error("Error SpeciesDetailsViewModel fetching data: \(error)")
            }
        }
    }
}
