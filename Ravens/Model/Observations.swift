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
    var results: [Observation]
}

let mockPoint = Point(type: "Point", coordinates: [52.013077-0.2, 4.713450+0.1]) // replace with mock Point data
let mockSpeciesDetail = SpeciesDetail(id: 1, scientific_name: "Limosa Limosa", name: "Grutto", group: 1) // replace with mock SpeciesDetail data
let mockUserDetail = UserDetail(id: 1, name: "Evert Jansen", avatar: URL(string: "https://example.com")) // replace with mock UserDetail data
let mockLocationDetail = LocationDetail(id: 1, name: "Ibiza", country_code: "NL-nl", permalink: "https://example.com") // replace with mock LocationDetail data

let mockObservation = Observation(
    id: 1,
    species: 2,
    date: "2023-01-01",
    time: "12:00",
    number: 15,
    sex: "male",
    point: mockPoint,
    accuracy: 1,
    notes: "Test notes",
    is_certain: true,
    is_escape: false,
    activity: 1,
    life_stage: 1,
    method: 1,
    substrate: 1,
    related_species: 1,
    obscurity: 1,
    has_photo: true,
    has_sound: false,
    counting_method: 1,
    embargo_date: "2023-01-01",
    uuid: "1234567890",
    externalReference: ["external1", "external2"],
    observer_location: mockPoint,
    transect_uuid: URL(string: "https://example.com"),
    species_detail: mockSpeciesDetail,
    rarity: 1,
    user: 1,
    user_detail: mockUserDetail,
    modified: "2023-01-01",
    species_group: 1,
    validation_status: "validated",
    location: 1,
    location_detail: mockLocationDetail,
    photos: ["https://waarneming.nl/media/photo/84399858.jpg", "https://waarneming.nl/media/photo/84399859.jpg"],
    sounds: ["sound1", "sound2"],
    permalink: "https://example.com",
    detail: "Test detail",
    code: "Test code"
)

// MARK: - Result
struct Observation: Codable, Identifiable {
    var id: Int?
    var species: Int?
    var date: String = "2023-01-01"
    var time: String?
    var number: Int = 0
    var sex: String = ""
    var point: Point
    var accuracy: Int?
    var notes: String?
    var is_certain: Bool = false
    var is_escape: Bool = false
    var activity: Int = 0
    var life_stage: Int = 0
    var method: Int?
    var substrate: Int?
    var related_species: Int?
    var obscurity: Int?
    var has_photo: Bool?
    var has_sound: Bool?
    var counting_method: Int?
    var embargo_date: String?
    var uuid: String?
    let externalReference: [String]?
//    var links: [String?]
//    var details: [String?]
    var observer_location: Point?
    var transect_uuid: URL?
    var species_detail: SpeciesDetail
    var rarity: Int = 0
    var user: Int = 0
    var user_detail: UserDetail?
    var modified: String?
    var species_group: Int?
    var validation_status: String = ""
    var location: Int?
    var location_detail: LocationDetail?
    var photos: [String]?
    var sounds: [String]?
    var permalink: String = ""
    
    var detail: String?
    var code: String?

}

// MARK: - UserDetail
struct UserDetail: Codable {
    var id: Int = 0
    var name: String = ""
    var avatar: URL?
}

struct SpeciesDetail: Codable, Identifiable {
    var id: Int = 0
    var scientific_name: String = ""
    var name: String = ""
    var group: Int = 0
}

struct Point: Codable {
    var type: String = ""
    var coordinates: [Double] = [0]
}

struct LocationDetail: Codable {
    var id: Int = 0
    var name: String = ""
    var country_code: String = ""
    var permalink: String = ""
}

struct Species: Codable, Identifiable {
    var id: Int { species }
    let species: Int
    let name: String
    let scientific_name: String
    let rarity: Int
    let native: Bool

    init(species: Int, name: String, scientific_name: String, rarity: Int, native: Bool) {
        self.species = species
        self.name = name
        self.scientific_name = scientific_name
        self.rarity = rarity
        self.native = native
    }
}


//    init(id: Int? = nil, species: Int? = nil, date: String, time: String? = nil, number: Int, sex: String, point: Point, accuracy: Int? = nil, notes: String? = nil, is_certain: Bool, is_escape: Bool, activity: Int, life_stage: Int, method: Int? = nil, substrate: Int? = nil, related_species: Int? = nil, obscurity: Int? = nil, has_photo: Bool? = nil, has_sound: Bool? = nil, counting_method: Int? = nil, embargo_date: String? = nil, uuid: String? = nil, externalReference: [String]?, observer_location: Point? = nil, transect_uuid: URL? = nil, species_detail: SpeciesDetail, rarity: Int, user: Int, user_detail: UserDetail? = nil, modified: String? = nil, species_group: Int? = nil, validation_status: String, location: Int? = nil, location_detail: LocationDetail? = nil, photos: [String]? = nil, sounds: [String]? = nil, permalink: String, detail: String? = nil, code: String? = nil) {
//        self.id = id
//        self.species = species
//        self.date = date
//        self.time = time
//        self.number = number
//        self.sex = sex
//        self.point = point
//        self.accuracy = accuracy
//        self.notes = notes
//        self.is_certain = is_certain
//        self.is_escape = is_escape
//        self.activity = activity
//        self.life_stage = life_stage
//        self.method = method
//        self.substrate = substrate
//        self.related_species = related_species
//        self.obscurity = obscurity
//        self.has_photo = has_photo
//        self.has_sound = has_sound
//        self.counting_method = counting_method
//        self.embargo_date = embargo_date
//        self.uuid = uuid
//        self.externalReference = externalReference
//        self.observer_location = observer_location
//        self.transect_uuid = transect_uuid
//        self.species_detail = species_detail
//        self.rarity = rarity
//        self.user = user
//        self.user_detail = user_detail
//        self.modified = modified
//        self.species_group = species_group
//        self.validation_status = validation_status
//        self.location = location
//        self.location_detail = location_detail
//        self.photos = photos
//        self.sounds = sounds
//        self.permalink = permalink
//        self.detail = detail
//        self.code = code
//    }