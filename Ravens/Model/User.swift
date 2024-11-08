//
//  User.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import Foundation

struct UserData: Codable {
    let id: Int
    let name: String
    let email: String
    let isMailAllowed: Bool
    let url: String
    let country: String
    let considerEmailConfirmed: Bool
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case isMailAllowed = "is_mail_allowed"
        case url
        case country
        case considerEmailConfirmed = "consider_email_confirmed"
        case avatar
    }
}

