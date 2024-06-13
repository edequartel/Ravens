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
        
    func fetchData(language: String, for speciesID: Int, onCompletion: (() -> Void)? = nil) {
        log.error("SpeciesDetailsViewModel speciesID: \(speciesID)")
        
        let url = endPoint(value: settings.selectedInBetween)+"species/\(speciesID)/"
        log.error("SpeciesDetailsViewModel url: \(url)")
        
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]
        
        AF.request(url, headers: headers).responseDecodable(of: SpeciesDetails.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.speciesDetails = data
                     onCompletion?()
                }
            case .failure(let error):
                self.log.error("Error SpeciesDetailsViewModel fetching data: \(error)")
                onCompletion?()
            }
        }
    }
}
