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
    
    var settings: Settings
    init(settings: Settings) {
        self.settings = settings
    }
    
    func fetchData(for speciesID: Int) {
        guard let url = URL(string: settings.endPoint()+"species/\(speciesID)/") else {
            return
        }
        log.info("SpeciesDetailsViewModel speciesID: \(speciesID)")
        
        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]
        log.verbose("SpeciesDetailsViewModel url: \(url)")
        
    
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
