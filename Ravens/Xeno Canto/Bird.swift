//
//  Model.swift
//  XC
//
//  Created by Eric de Quartel on 25/11/2024.
//

import Foundation

// MARK: - BirdResponse
struct BirdResponse: Codable {
  let numRecordings: String
  let numSpecies: String
  let page: Int
  let numPages: Int
  let recordings: [Bird]
}

// MARK: - Bird
struct Bird: Codable, Identifiable {
  let id: UUID = UUID()  // Generates unique ID per instance
  let idSpecies: String
  let gen: String?
  let species: String?
  let ssp: String?
  let group: String?
  let english: String?
  let rec: String?
  let cnt: String?
  let loc: String?
  let lat: String?
  let lng: String?
  let alt: String?
  let type: String?
  let sex: String?
  let stage: String?
  let method: String?
  let url: String?
  let file: String?
  let fileName: String?
  let sono: Sono?
  let osci: Osci?
  let lic: String?
  let quality: String?
  let length: String?
  let time: String?
  let date: String?
  let uploaded: String?
  let also: [String]?
  let rmk: String?
  let birdSeen: String?
  let animalSeen: String?
  let playbackUsed: String?
  let temp: String?
  let regnr: String?
  let auto: String?
  let dvc: String?
  let mic: String?
  let smp: String?

  enum CodingKeys: String, CodingKey {
    case idSpecies = "id"
    case gen
    case species = "sp"
    case ssp, group
    case english = "en"
    case rec, cnt, loc, lat, lng, alt, type, sex, stage, method, url, file
    case fileName = "file-name"
    case sono, osci, lic
    case quality = "q"
    case length, time, date, uploaded, also, rmk
    case birdSeen = "bird-seen"
    case animalSeen = "animal-seen"
    case playbackUsed = "playback-used"
    case temp, regnr, auto, dvc, mic, smp
  }
}

// MARK: - Sono
struct Sono: Codable {
  let small: String
  let med: String
  let large: String
  let full: String
}

// MARK: - Osci
struct Osci: Codable {
  let small: String
  let med: String
  let large: String
}
