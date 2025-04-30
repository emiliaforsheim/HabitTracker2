//
//  HabitModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI
import FirebaseFirestore

struct HabitModel: Identifiable {
    var id = UUID()
    var name: String
    var note: String
    var color: Color
    var subtasks: [Subtask]
    var startDate: Date
    var endDate: Date?
    
    struct Subtask: Identifiable, Codable {
        var id = UUID()
        var title: String
        var isCompleted: Bool
    }
}
