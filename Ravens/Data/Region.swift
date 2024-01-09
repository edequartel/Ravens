//
//  Region.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation

struct Region: Identifiable, Codable {
    var id: Int
    var type: Int
    var name: String
    var continent: Int?
    var iso: String?
}
