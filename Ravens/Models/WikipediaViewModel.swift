//
//  WikipediaViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 16/05/2024.
//

import Foundation
import Alamofire

import Foundation
import Alamofire

class WikipediaViewModel: ObservableObject {
    @Published var pageDetail = WikipediaPageDetail(title: "", extract: "", fullurl: "", thumbnail: nil, categories: [])
    @Published var isLoading = false

    func fetchDetails(topic: String) {
        isLoading = true
        let parameters = [
            "action": "query",
            "format": "json",
            "prop": "extracts|info|pageimages|categories",
            "exintro": "",
            "explaintext": "true",
            "inprop": "url",
            "pithumbsize": "500",
            "titles": topic,
            "cllimit": "max"
        ]
        let url = "https://nl.wikipedia.org/w/api.php"

        AF.request(url, parameters: parameters).responseDecodable(of: WikipediaResult.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                if let pages = response.value?.query.pages.values.first {
                    self.pageDetail = pages
                }
            }
        }
    }
}

struct WikipediaResult: Decodable {
    let query: Query
    struct Query: Decodable {
        let pages: [String: WikipediaPageDetail]
    }
}

struct WikipediaPageDetail: Decodable {
    let title: String
    let extract: String
    let fullurl: String
    let thumbnail: WikipediaThumbnail?
    let categories: [WikipediaCategory]

    struct WikipediaThumbnail: Decodable {
        let source: String
        let width: Int
        let height: Int
    }

    struct WikipediaCategory: Decodable {
        let title: String
    }
}
