//
//  UserModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import Foundation

struct UserModel: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
