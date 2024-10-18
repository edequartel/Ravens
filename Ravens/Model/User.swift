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
    let is_mail_allowed: Bool
    let url: String
    let country: String
    let consider_email_confirmed: Bool
    let avatar: String?
}
