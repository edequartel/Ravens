//
//  ViewModel.swift
//  XC
//
//  Created by Eric de Quartel on 25/11/2024.
//
import SwiftUI
import Alamofire

class BirdViewModel: ObservableObject {

  @Published var birds: [Bird] = []
  @Published var totalRecordings: Int = 0
  @Published var totalPages: Int = 0
  @Published var currentPage: Int = 0
  @Published var totalSpecies: Int = 0
  @Published var isLoading = false
  @Published var errorMessage: String?

  var hasFetchedBirds: Bool = false //for progressview

  func fetchBirds(name: String, onComplete: (() -> Void)? = nil) {
    let checkedName = name.lowercased()
    let url = "https://xeno-canto.org/api/2/recordings?query=gen:\(checkedName)&page=1"

    print(url)

    isLoading = true
    errorMessage = nil

    AF.request(url).responseDecodable(of: BirdResponse.self) { response in
      DispatchQueue.main.async {
        self.isLoading = false
        switch response.result {
        case .success(let birdResponse):
          self.birds = birdResponse.recordings
          self.totalRecordings = Int(birdResponse.numRecordings) ?? 0
          self.totalPages = birdResponse.numPages
          self.currentPage = birdResponse.page
          self.totalSpecies = Int(birdResponse.numSpecies) ?? 0

          onComplete?() // Execute completion handler

          self.hasFetchedBirds = true // Mark as fetched
        case .failure(let error):
          self.errorMessage = "Failed to fetch birds: \(error.localizedDescription)"
        }
      }
    }
  }

}
