//
//  XenoCantoService.swift
//  Ravens
//

import Foundation

protocol XenoCantoServicing {
  func recordings(for scientificName: String) async throws -> [XenoCantoRecording]
}

final class XenoCantoService: XenoCantoServicing {
  private enum API {
    static let endpoint = "https://xeno-canto.org/api/3/recordings"
    static let key = "14ebe5991397d4cbf818d54f31a9014d250a1855"
    static let perPage = 100
  }

  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  func recordings(for scientificName: String) async throws -> [XenoCantoRecording] {
    var components = URLComponents(string: API.endpoint)
    components?.queryItems = [
      URLQueryItem(name: "query", value: Self.query(for: scientificName)),
      URLQueryItem(name: "key", value: API.key),
      URLQueryItem(name: "page", value: "1"),
      URLQueryItem(name: "per_page", value: "\(API.perPage)")
    ]

    guard let url = components?.url else {
      throw URLError(.badURL)
    }

    let (data, response) = try await session.data(from: url)
    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
      throw URLError(.badServerResponse)
    }

    let birdResponse = try JSONDecoder().decode(BirdResponse.self, from: data)
    return birdResponse.recordings
  }

  static func query(for scientificName: String) -> String {
    let parts = scientificName
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: " ")
      .map(String.init)

    guard let genus = parts.first else {
      return "grp:birds"
    }

    guard parts.count > 1 else {
      return #"gen:"\#(genus)""#
    }

    return #"gen:"\#(genus)" sp:"\#(parts[1])""#
  }
}
