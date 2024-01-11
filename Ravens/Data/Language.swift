//
//  Language.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation

struct Language: Codable {
    let count: Int
    let next, previous: URL? //?? naar kijken
    let results: [Result]
}

struct Result: Codable {
    let code, name_en, name_native: String
}
