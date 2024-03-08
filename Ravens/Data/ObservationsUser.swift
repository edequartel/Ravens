//////
//////  ObservationsUser.swift
//////  Ravens
//////
//////  Created by Eric de Quartel on 04/03/2024.
//////
////
import Foundation
//
//// MARK: - ObservationsUser //
struct ObservationsUser: Codable {
    var count: Int?
    var next, previous: String?
    var results: [ObservationSpecies]
}
