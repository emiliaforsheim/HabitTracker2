//
//  RootView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-05-01.
//

import SwiftUI

struct RootView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            TabBar {
                isLoggedIn = false
            }
        } else {
            LoginView {
                isLoggedIn = true
            }
        }
    }
}
