//
//  TabBar.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//

import SwiftUI

struct TabBar: View {
    
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(0)
            
            HabitView()
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
