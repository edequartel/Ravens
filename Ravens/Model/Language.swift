//
//  Language.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation

struct Language: Codable, Hashable {
    let count: Int
    let next, previous: URL?
    let results: [Result]
}

struct Result: Codable, Hashable {
    let code: String
    let nameEn: String
    let nameNative: String

    enum CodingKeys: String, CodingKey {
        case code
        case nameEn = "name_en"
        case nameNative = "name_native"
    }
}


