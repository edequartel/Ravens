//
//  Location.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//
import Foundation
import SwiftUI

struct ApiResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [LocationJSON] // This is an array of LocationJSON
}

struct LocationJSON: Decodable {
    let id: Int
    let name: String
    let country_code: String
    let permalink: String
}
