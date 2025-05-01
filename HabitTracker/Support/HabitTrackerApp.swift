//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//

import SwiftUI
import FirebaseCore

@main
struct HabitTrackerApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
