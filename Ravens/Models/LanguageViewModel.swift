//
//  LanguageViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class LanguagesViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var language: Language?

//    func fetchLanguageData(completion: (() -> Void)? = nil) {
//        log.info("fetchData LanguageViewModel \(endPoint)languages")
//        let url = endPoint+"languages/"
//        
//        AF.request(url).responseDecodable(of: Language.self) { response in
//            switch response.result {
//            case .success(let language):
//                DispatchQueue.main.async {
//                    self.language = language
//                    completion?() // call the completion handler if it exists
//                }
//            case .failure(let error):
//                self.log.error("Error LanguageViewModel: \(error)")
//            }
//        }
//    }
}

extension LanguagesViewModel {
    func fetchLanguageData() async throws {
        // Your fetching code here
        log.info("fetchData LanguageViewModel \(endPoint)languages")
        let url = endPoint+"languages/"
        
        AF.request(url).responseDecodable(of: Language.self) { response in
            switch response.result {
            case .success(let language):
                DispatchQueue.main.async {
                    self.language = language
//                    completion?()  //call the completion handler if it exists
                }
            case .failure(let error):
                self.log.error("Error LanguageViewModel: \(error)")
            }
        }
    }
}
