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
        
    func fetchData(language: String, for speciesID: Int) {
        guard let url = URL(string: endPoint()+"species/\(speciesID)/") else {
            return
        }
        log.error("SpeciesDetailsViewModel speciesID: \(speciesID)")
        
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]
        log.error("SpeciesDetailsViewModel url: \(url)")
        
    
        AF.request(url, headers: headers).responseDecodable(of: SpeciesDetails.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.speciesDetails = data
                }
            case .failure(let error):
                self.log.error("Error SpeciesDetailsViewModel fetching data: \(error)")
            }
        }
    }
}
