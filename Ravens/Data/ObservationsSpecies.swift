// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   var observationsSpecies = try? JSONDecoder().decode(ObservationsSpecies.self, from: jsonData)

import Foundation

// MARK: - ObservationsSpecies
struct ObservationsSpecies: Codable {
    var count: Int?
    var next, previous: String?
    var results: [ObservationSpecies]
}

// MARK: - Result
struct ObservationSpecies: Codable, Identifiable {
    var id: Int?
    var species: Int = 0
    var date: String = "2023-01-01"
    var time: String?
    var number: Int = 0
    var sex: String = ""
    var point: Point
    var accuracy: Int = 0
    var notes: String?
    var is_certain: Bool = false
    var is_escape: Bool = false
    var activity: Int = 0
    var life_stage: Int = 0
    var method: Int?
    var substrate: Int?
    var related_species: Int = 0
    var obscurity: Int = 0
    var counting_method: Int?
    var embargo_date: String
    var uuid: String?
    let externalReference: [String]?
    var links: [String?]
//    var details: [String?]
    var observer_location: Point?
    var transect_uuid: URL?
    var species_detail: SpeciesDetail
    var rarity: Int = 0
    var user: Int = 0
    var user_detail: UserDetail
    var modified: String = ""
    var species_group: Int = 0
    var validation_status: String = ""
    var location: Int = 0
    var location_detail: LocationDetail
    var photos: [String]
    var sounds: [String]
    var permalink: String = ""
}

// MARK: - UserDetail
struct UserDetail: Codable {
    var id: Int = 0
    var name: String = ""
    var avatar: URL?
}
