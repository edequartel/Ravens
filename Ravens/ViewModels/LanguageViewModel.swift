//
//  LanguageViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class LanguageViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var language: Language?
    
    init() {
        fetchData()
    }

    func fetchData() {
        log.info("fetchData LanguageViewModel")
        AF.request(endPoint+"languages/").responseDecodable(of: Language.self) { response in
            switch response.result {
            case .success(let language):
                DispatchQueue.main.async {
                    self.language = language
                }
            case .failure(let error):
                self.log.error("Error LanguageViewModel: \(error)")
            }
        }
    }
}

