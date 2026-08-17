//
//  BirdSoundServiceTests.swift
//  RavensTests
//

import XCTest
@testable import Ravens

final class BirdSoundServiceTests: XCTestCase {
  func testExactXenoCantoMatchDoesNotResolveTaxonomy() async throws {
    let recording = try makeRecording(id: "1")
    let xenoCanto = FakeXenoCantoService(recordingsByName: [
      "Parus major": [recording]
    ])
    let resolver = FakeTaxonomyResolver(candidatesByName: [
      "Parus major": ["Parus major", "Major major"]
    ])
    let service = BirdSoundService(xenoCantoService: xenoCanto, taxonomyResolver: resolver)

    let recordings = try await service.recordings(for: "Parus major")

    XCTAssertEqual(recordings.map(\.idSpecies), ["1"])
    XCTAssertEqual(xenoCanto.queries, ["Parus major"])
    XCTAssertEqual(resolver.queries, [])
  }

  func testAsturGentilisResolvesToAccipiterGentilis() async throws {
    let recording = try makeRecording(id: "2", gen: "Accipiter", species: "gentilis")
    let xenoCanto = FakeXenoCantoService(recordingsByName: [
      "Astur gentilis": [],
      "Accipiter gentilis": [recording]
    ])
    let resolver = FakeTaxonomyResolver(candidatesByName: [
      "Astur gentilis": ["Astur gentilis", "Accipiter gentilis"]
    ])
    let service = BirdSoundService(xenoCantoService: xenoCanto, taxonomyResolver: resolver)

    let recordings = try await service.recordings(for: "Astur gentilis")

    XCTAssertEqual(recordings.map(\.idSpecies), ["2"])
    XCTAssertEqual(xenoCanto.queries, ["Astur gentilis", "Accipiter gentilis"])
    XCTAssertEqual(resolver.queries, ["Astur gentilis"])
  }

  func testGBIFFailureReturnsEmptyRecordings() async throws {
    let xenoCanto = FakeXenoCantoService(recordingsByName: [
      "Astur gentilis": []
    ])
    let resolver = FakeTaxonomyResolver(error: URLError(.notConnectedToInternet))
    let service = BirdSoundService(xenoCantoService: xenoCanto, taxonomyResolver: resolver)

    let recordings = try await service.recordings(for: "Astur gentilis")

    XCTAssertTrue(recordings.isEmpty)
    XCTAssertEqual(xenoCanto.queries, ["Astur gentilis"])
    XCTAssertEqual(resolver.queries, ["Astur gentilis"])
  }

  func testNoXenoCantoRecordingsUnderAnyCandidateName() async throws {
    let xenoCanto = FakeXenoCantoService(recordingsByName: [
      "Astur gentilis": [],
      "Accipiter gentilis": []
    ])
    let resolver = FakeTaxonomyResolver(candidatesByName: [
      "Astur gentilis": ["Astur gentilis", "Accipiter gentilis"]
    ])
    let service = BirdSoundService(xenoCantoService: xenoCanto, taxonomyResolver: resolver)

    let recordings = try await service.recordings(for: "Astur gentilis")

    XCTAssertTrue(recordings.isEmpty)
    XCTAssertEqual(xenoCanto.queries, ["Astur gentilis", "Accipiter gentilis"])
  }

  func testTaxonomyResolverRemovesDuplicateSynonymNames() async throws {
    MockURLProtocol.responses = [
      "/v1/species/match": """
      {"scientificName":"Astur gentilis","canonicalName":"Astur gentilis"}
      """,
      "/v1/species/search": """
      {"results":[
        {"key":10,"acceptedKey":20,"scientificName":"Astur gentilis (Linnaeus, 1758)","canonicalName":"Astur gentilis","accepted":"Accipiter gentilis Linnaeus, 1758","species":"Accipiter gentilis"},
        {"key":11,"acceptedKey":20,"scientificName":"Astur gentilis","canonicalName":"Astur gentilis","accepted":"Accipiter gentilis Linnaeus, 1758","species":"Accipiter gentilis"}
      ]}
      """,
      "/v1/species/20/synonyms": """
      {"results":[
        {"scientificName":"Astur gentilis","canonicalName":"Astur gentilis","accepted":"Accipiter gentilis Linnaeus, 1758","species":"Accipiter gentilis"}
      ]}
      """
    ]

    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    let resolver = TaxonomyResolver(session: URLSession(configuration: configuration))

    let candidates = try await resolver.candidateNames(for: "Astur gentilis")

    XCTAssertEqual(candidates, ["Astur gentilis", "Accipiter gentilis"])
  }

  private func makeRecording(id: String, gen: String = "Parus", species: String = "major") throws -> XenoCantoRecording {
    let json = """
    {
      "id": "\(id)",
      "gen": "\(gen)",
      "sp": "\(species)",
      "grp": "birds"
    }
    """

    return try JSONDecoder().decode(XenoCantoRecording.self, from: Data(json.utf8))
  }
}

private final class FakeXenoCantoService: XenoCantoServicing {
  private let recordingsByName: [String: [XenoCantoRecording]]
  private(set) var queries: [String] = []

  init(recordingsByName: [String: [XenoCantoRecording]]) {
    self.recordingsByName = recordingsByName
  }

  func recordings(for scientificName: String) async throws -> [XenoCantoRecording] {
    queries.append(scientificName)
    return recordingsByName[scientificName] ?? []
  }
}

private final class FakeTaxonomyResolver: TaxonomyResolving {
  private let candidatesByName: [String: [String]]
  private let error: Error?
  private(set) var queries: [String] = []

  init(candidatesByName: [String: [String]] = [:], error: Error? = nil) {
    self.candidatesByName = candidatesByName
    self.error = error
  }

  func candidateNames(for scientificName: String) async throws -> [String] {
    queries.append(scientificName)
    if let error {
      throw error
    }
    return candidatesByName[scientificName] ?? [scientificName]
  }
}

private final class MockURLProtocol: URLProtocol {
  static var responses: [String: String] = [:]

  override static func canInit(with request: URLRequest) -> Bool {
    true
  }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let url = request.url,
          let responseBody = Self.responses.first(where: { url.path.contains($0.key) })?.value else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }

    let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"]
    )!

    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data(responseBody.utf8))
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
