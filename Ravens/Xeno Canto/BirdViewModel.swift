//
//  ViewModel.swift
//  XC
//
//  Created by Eric de Quartel on 25/11/2024.
//
import SwiftUI
import Alamofire

class BirdViewModel: ObservableObject {
  private enum XenoCantoAPI {
    static let endpoint = "https://xeno-canto.org/api/3/recordings"
    static let key = "14ebe5991397d4cbf818d54f31a9014d250a1855"
    static let perPage = 100
  }

  @Published var birds: [Bird] = []
  @Published var totalRecordings: Int = 0
  @Published var totalPages: Int = 0
  @Published var currentPage: Int = 0
  @Published var totalSpecies: Int = 0
  @Published var isLoading = false
  @Published var errorMessage: String?

  var hasFetchedBirds: Bool = false // for progressview

  func fetchBirds(name: String, onComplete: ((_ numRecordings: Int) -> Void)? = nil) {
    let parameters: Parameters = [
      "query": xenoCantoQuery(for: name),
      "key": XenoCantoAPI.key,
      "page": 1,
      "per_page": XenoCantoAPI.perPage
    ]

    isLoading = true
    errorMessage = nil

    AF.request(XenoCantoAPI.endpoint, parameters: parameters)
      .validate()
      .responseDecodable(of: BirdResponse.self) { response in
      DispatchQueue.main.async {
        self.isLoading = false

        switch response.result {
        case .success(let birdResponse):
          self.birds = birdResponse.recordings
          self.totalRecordings = Int(birdResponse.numRecordings) ?? 0
          self.totalPages = birdResponse.numPages
          self.currentPage = birdResponse.page
          self.totalSpecies = Int(birdResponse.numSpecies) ?? 0
          self.hasFetchedBirds = true
          onComplete?(self.totalRecordings)

        case .failure(let error):
          self.errorMessage = "Failed to fetch birds: \(error.localizedDescription)"
          onComplete?(0) // or use -1 if you want to indicate failure explicitly
        }
      }
    }
  }

  private func xenoCantoQuery(for scientificName: String) -> String {
    let parts = scientificName
      .lowercased()
      .split(separator: " ")
      .map(String.init)

    guard let genus = parts.first else {
      return "grp:birds"
    }

    if parts.count == 1 {
      return "gen:\(genus)"
    }

    if parts.count == 2 {
      return "gen:\(genus) sp:\(parts[1])"
    }

    return "gen:\(genus) sp:\(parts[1]) ssp:\"\(parts.joined(separator: " "))\""
  }
}
