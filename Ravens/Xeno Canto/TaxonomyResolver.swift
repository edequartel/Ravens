//
//  TaxonomyResolver.swift
//  Ravens
//

import Foundation

protocol TaxonomyResolving {
  func candidateNames(for scientificName: String) async throws -> [String]
}

final class TaxonomyResolver: TaxonomyResolving {
  private enum API {
    static let baseURL = "https://api.gbif.org/v1/species"
  }

  private let session: URLSession
  private var cache: [String: [String]] = [:]

  init(session: URLSession = .shared) {
    self.session = session
  }

  func candidateNames(for scientificName: String) async throws -> [String] {
    let originalName = scientificName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !originalName.isEmpty else { return [] }

    let cacheKey = originalName.lowercased()
    if let cachedNames = cache[cacheKey] {
      return cachedNames
    }

    var candidates = OrderedScientificNames()
    candidates.append(originalName)

    async let matchResponse = match(name: originalName)
    async let searchResponse = search(name: originalName)

    let match = try await matchResponse
    candidates.append(match.acceptedScientificName)
    candidates.append(match.scientificName)
    candidates.append(match.canonicalName)

    let search = try await searchResponse
    var synonymKeys = Set<Int>()

    for result in search.results {
      candidates.append(result.accepted)
      candidates.append(result.species)
      candidates.append(result.canonicalName)
      candidates.append(result.scientificName)

      if let key = result.acceptedKey ?? result.speciesKey ?? result.key {
        synonymKeys.insert(key)
      }
    }

    for key in synonymKeys.prefix(3) {
      let synonyms = try await synonyms(for: key)
      for synonym in synonyms.results {
        candidates.append(synonym.accepted)
        candidates.append(synonym.species)
        candidates.append(synonym.canonicalName)
        candidates.append(synonym.scientificName)
      }
    }

    let names = candidates.values
    cache[cacheKey] = names
    return names
  }

  private func match(name: String) async throws -> GBIFMatchResponse {
    var components = URLComponents(string: "\(API.baseURL)/match")
    components?.queryItems = [
      URLQueryItem(name: "name", value: name),
      URLQueryItem(name: "kingdom", value: "Animalia")
    ]

    return try await decoded(components: components)
  }

  private func search(name: String) async throws -> GBIFSearchResponse {
    var components = URLComponents(string: "\(API.baseURL)/search")
    components?.queryItems = [
      URLQueryItem(name: "q", value: name),
      URLQueryItem(name: "rank", value: "SPECIES"),
      URLQueryItem(name: "limit", value: "50")
    ]

    return try await decoded(components: components)
  }

  private func synonyms(for key: Int) async throws -> GBIFSearchResponse {
    var components = URLComponents(string: "\(API.baseURL)/\(key)/synonyms")
    components?.queryItems = [
      URLQueryItem(name: "limit", value: "50")
    ]

    return try await decoded(components: components)
  }

  private func decoded<T: Decodable>(components: URLComponents?) async throws -> T {
    guard let url = components?.url else {
      throw URLError(.badURL)
    }

    let (data, response) = try await session.data(from: url)
    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
      throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode(T.self, from: data)
  }
}

private struct OrderedScientificNames {
  private var seen = Set<String>()
  private(set) var values: [String] = []

  mutating func append(_ name: String?) {
    guard let normalizedName = Self.normalizedScientificName(name),
          !seen.contains(normalizedName.lowercased()) else {
      return
    }

    seen.insert(normalizedName.lowercased())
    values.append(normalizedName)
  }

  private static func normalizedScientificName(_ name: String?) -> String? {
    guard let name else { return nil }

    let cleanedName = name
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)

    let words = cleanedName.split(separator: " ").map(String.init)
    guard words.count >= 2 else { return nil }

    return "\(words[0]) \(words[1])"
  }
}

private struct GBIFMatchResponse: Decodable {
  let scientificName: String?
  let canonicalName: String?
  let acceptedScientificName: String?
}

private struct GBIFSearchResponse: Decodable {
  let results: [GBIFTaxon]
}

private struct GBIFTaxon: Decodable {
  let key: Int?
  let acceptedKey: Int?
  let speciesKey: Int?
  let scientificName: String?
  let canonicalName: String?
  let accepted: String?
  let species: String?
}
