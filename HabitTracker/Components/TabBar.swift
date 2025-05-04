//
//  TabBar.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//

import SwiftUI

struct TabBar: View {
    
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(0)
            
            HabitView(viewModel: viewModel)
                .tabItem {
                    Label("Habits", systemImage: "checklist")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .tint(.black)
    }
}

#Preview {
    TabBar()
}
