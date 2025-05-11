//
//  HabitModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI
import FirebaseFirestore

struct HabitModel: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var note: String
    var colorHex: String
    var subtasks: [Subtask]
    var startDate: Date
    var endDate: Date?
    var isForever: Bool = false
    var completionByDate: [String: Bool]? = nil
    var subtaskCompletionByDate: [String: [UUID: Bool]]? = nil
    var currentStreak: Int = 0
    var lastCompletedDate: Date?

    struct Subtask: Identifiable, Codable, Equatable {
        var id = UUID()
        var title: String
        var isCompleted: Bool
    }

    var color: Color {
        Color(hex: colorHex)
    }
}
