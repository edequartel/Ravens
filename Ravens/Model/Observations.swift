// This file was generated from JSON Schema using quicktype, do not modify it directly.
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   var observationsSpecies = try? JSONDecoder().decode(ObservationsSpecies.self, from: jsonData)

import Foundation

// MARK: - Observations //
struct Observations: Codable {
  var count: Int?
  var next, previous: URL?
  var results: [Observation]? //?? madeoptional
}

//let id: UUID = UUID()

struct Observation: Codable, Identifiable, Equatable {
  let id: UUID = UUID()
//  let id: UUID
  var idObs: Int?
  var species: Int?
  var date: String = "2023-01-01"
  var time: String?
  var number: Int = 0
  var sex: String = ""
  var point: Point
  var accuracy: Int?
  var notes: String?
  var isCertain: Bool = false
  var isEscape: Bool = false
  var activity: Int = 0
  var lifeStage: Int = 0
  var method: Int?
  var substrate: Int?
  var relatedSpecies: Int?
  var obscurity: Int?
  var hasPhoto: Bool?
  var hasSound: Bool?
  var countingMethod: Int?
  var embargoDate: String?
  var uuid: String?
  var externalReference: String?
  var observerLocation: Point?
  var transectUUID: URL?
  var speciesDetail: SpeciesDetail
  var rarity: Int = 0
  var user: Int = 0
  var userDetail: UserDetail?
  var modified: String?
  var speciesGroup: Int?
  var validationStatus: String = ""
  var location: Int?
  var locationDetail: LocationDetail?
  var photos: [String]?
  var sounds: [String]?
  var permalink: String = ""

  var detail: String?
  var code: String?

  var timeDate: Date?

  enum CodingKeys: String, CodingKey {
    case idObs = "id"
    case species
    case date
    case time
    case number
    case sex
    case point
    case accuracy
    case notes
    case isCertain = "is_certain"
    case isEscape = "is_escape"
    case activity
    case lifeStage = "life_stage"
    case method
    case substrate
    case relatedSpecies = "related_species"
    case obscurity
    case hasPhoto = "has_photo"
    case hasSound = "has_sound"
    case countingMethod = "counting_method"
    case embargoDate = "embargo_date"
    case uuid
    case externalReference = "external_reference"
    case observerLocation = "observer_location"
    case transectUUID = "transect_uuid"
    case speciesDetail = "species_detail"
    case rarity
    case user
    case userDetail = "user_detail"
    case modified
    case speciesGroup = "species_group"
    case validationStatus = "validation_status"
    case location
    case locationDetail = "location_detail"
    case photos
    case sounds
    case permalink
    case detail
    case code
  }
}


// MARK: - UserDetail
struct UserDetail: Codable, Equatable {
  var id: Int = 0
  var name: String = ""
  var avatar: URL?
}

struct SpeciesDetail: Codable, Identifiable, Equatable {
  var id: Int = 0
  var scientificName: String = ""
  var name: String = ""
  var group: Int = 0

  enum CodingKeys: String, CodingKey {
    case id
    case scientificName = "scientific_name"
    case name
    case group
  }
}


struct Point: Codable, Equatable {
  var type: String = ""
  var coordinates: [Double] = [0]
}

struct LocationDetail: Codable, Equatable {
  var id: Int = 0
  var name: String = ""
  var countryCode: String = ""
  var permalink: String = ""

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case countryCode = "country_code"
    case permalink
  }
}

struct Species: Codable, Identifiable, Equatable { //equatable
  var id = UUID()  // Unique identifier for SwiftUI
  let speciesId: Int  // Maps to JSON `id`
  let name: String
  let scientificName: String
  let rarity: Int
  let native: Bool

  // Adding recent observations
  var time: String?
  var date: String?
  var nrof: Int?
  var dateTime: Date?
  var recent: Bool?

  // Map JSON keys
  private enum CodingKeys: String, CodingKey {
    case speciesId = "species" // Maps JSON `species` to `species_id`
    case name
    case scientificName = "scientific_name"
    case rarity
    case native
    case time
    case date
    case nrof
    case dateTime
  }

  init(speciesId: Int, name: String, scientificName: String, rarity: Int, native: Bool, time: String?, date: String?) {
    self.speciesId = speciesId
    self.name = name
    self.scientificName = scientificName
    self.rarity = rarity
    self.native = native
    self.time = time
    self.date = date
  }
}

//{ //equatable
//    var id = UUID()  // Unique identifier for SwiftUI
//    let speciesId: Int  // Maps to JSON `id`
//    let name: String
//    let scientificName: String
//    let rarity: Int
//    let native: Bool
//
//    // Adding recent observations
//    var time: String?
//    var date: String?
//    var nrof: Int?
//    var dateTime: Date?
//
//    // Map JSON keys
//    private enum CodingKeys: String, CodingKey {
//        case speciesId = "species" // Maps JSON `species` to `species_id`
//        case name
//        case scientificName = "scientific_name"
//        case rarity
//        case native
//        case time
//        case date
//        case nrof
//        case dateTime
//    }
//
//    init(speciesId: Int, name: String, scientificName: String, rarity: Int, native: Bool, time: String?, date: String?) {
//        self.speciesId = speciesId
//        self.name = name
//        self.scientificName = scientificName
//        self.rarity = rarity
//        self.native = native
//        self.time = time
//        self.date = date
//    }
//}

let mockPoint = Point(type: "Point", coordinates: [52.013077-0.2, 4.713450+0.1]) // replace with mock Point data
let mockSpeciesDetail = SpeciesDetail(id: 1, scientificName: "Limosa Limosa", name: "Grutto", group: 1) // replace with mock SpeciesDetail data
let mockUserDetail = UserDetail(id: 1, name: "Evert Jansen", avatar: URL(string: "https://example.com")) // replace with mock UserDetail data
let mockLocationDetail = LocationDetail(id: 1, name: "Ibiza", countryCode: "NL-nl", permalink: "https://example.com") // replace with mock LocationDetail data

let mockObservation = Observation(
//  id: 0,
  idObs: 1,
  species: 2,
  date: "2023-01-01",
  time: "12:00",
  number: 15,
  sex: "male",
  point: mockPoint,
  accuracy: 1,
  notes: "Test notes",
  isCertain: true,
  isEscape: false,
  activity: 1,
  lifeStage: 1,
  method: 1,
  substrate: 1,
  relatedSpecies: 1,
  obscurity: 1,
  hasPhoto: true,
  hasSound: false,
  countingMethod: 1,
  embargoDate: "2023-01-01",
  uuid: "1234567890",
  externalReference: "external1",
  observerLocation: mockPoint,
  transectUUID: URL(string: "https://example.com"),
  speciesDetail: mockSpeciesDetail,
  rarity: 1,
  user: 1,
  userDetail: mockUserDetail,
  modified: "2023-01-01",
  speciesGroup: 1,
  validationStatus: "validated",
  location: 1,
  locationDetail: mockLocationDetail,
  photos: ["https://waarneming.nl/media/photo/84399858.jpg", "https://waarneming.nl/media/photo/84399859.jpg"],
  sounds: ["sound1", "sound2"],
  permalink: "https://example.com",
  detail: "Test detail",
  code: "Test code"
)
