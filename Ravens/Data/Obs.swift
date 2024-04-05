// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let obs = try? JSONDecoder().decode(Obs.self, from: jsonData)

import Foundation

// MARK: - Obs
struct Obs: Codable, Identifiable {
    let accuracy: Int?
    let activity, lifeStage: Int?
    let code: String?
    let counting_method: Int?
    let date: String
    let detail: String?
    let embargo_date: String?
    let externalReference: String?
    let is_certain, is_escape: Bool?
    var id: Int
    let location: Int?
    let location_detail: LocationDetail?
    let method: Int?
    let modified: String?
    var number: Int
    let notes: String?
    let obscurity, related_species, substrate: Int?
    let permalink: String
    let photos: [String]
    let point: Point
    let rarity, user: Int?
    let sex: String
    var species: Int = 0
    let species_detail: SpeciesDetail
    let species_group: Int?
    let sounds: [String]
    var time: String?
    let transectUUID: String?
    let user_detail: UserDetail?
    let uuid: String?
    let validation_status: String?
    // let links, details: [String]
    // let observer_location: String? is a geoJSON
}

//struct Obs: Codable, Identifiable {
//    var id: Int
//    var species: Int = 0
//    var date: String
//    var time: String? // Use String? instead of NSNull
//    var number: Int
//    let sex: String
//    let point: Point
//    let accuracy: Int?
//    let notes: String?
//    let is_certain, is_escape: Bool?
//    let activity, lifeStage: Int?
//    let method: Int? // Use String? instead of NSNull
//    let substrate, related_species, obscurity, counting_method: Int?
//    let embargo_date: String?
//    let uuid: String? // Use String? instead of NSNull
//    let externalReference: String?
////    let links, details: [String]
////    let observer_location: String? is a geoJSON
//    let transectUUID: String? // Use String? instead of NSNull
//    let species_detail: SpeciesDetail
//    let rarity, user: Int?
//    let user_detail: UserDetail?
//    let modified: String?
//    let species_group: Int?
//    let validation_status: String?
//    let location: Int?
//    let location_detail: LocationDetail?
//    let photos: [String]
//    let sounds: [String]
//    let permalink: String
//    
//    let detail: String?
//    let code: String?
//}

//{
//  "detail": "Not found.",
//  "code": "not-found"
//}
