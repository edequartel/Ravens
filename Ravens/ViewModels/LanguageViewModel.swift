//
//  LanguageViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation

import Alamofire

class LanguageViewModel: ObservableObject {
    @Published var language: Language?
    
    init() {
        fetchData()
    }

    func fetchData() {
        print("fetchData LanguageViewModel")
        AF.request("https://waarneming.nl/api/v1/languages/").responseDecodable(of: Language.self) { response in
            switch response.result {
            case .success(let language):
                DispatchQueue.main.async {
                    self.language = language
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

