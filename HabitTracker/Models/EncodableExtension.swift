//
//  EncodableExtension.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import Foundation

// MARK: - Extension to convert any Encodable object to a dictionary
extension Encodable {
    func asDict() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}
