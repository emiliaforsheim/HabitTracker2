//
//  CalendarView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//


import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var showingAddHabit = false
    @State private var habits: [HabitModel] = []

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Coral"), Color("Purple"), Color("Blue")]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                DatePicker(
                    "Välj datum",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal)

                let habitsForSelectedDate = habits.filter { habit in
                    let start = Calendar.current.startOfDay(for: habit.startDate)
                    let end = habit.endDate != nil ? Calendar.current.startOfDay(for: habit.endDate!) : nil
                    let selected = Calendar.current.startOfDay(for: selectedDate)

                    if let end = end {
                        return selected >= start && selected <= end
                    } else {
                        return selected >= start
                    }
                }

                if habitsForSelectedDate.isEmpty {
                    Text("No habits for this date.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.headline)
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: -15) {
                            ForEach(habitsForSelectedDate) { habit in
                                TaskView(task: habit)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top, 20)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .frame(width: 55, height: 55)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    }
                    .padding()
                }
            }

            if showingAddHabit {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                AddHabit(showPopup: $showingAddHabit, selectedStartDate: selectedDate) { newHabit in
                    habits.append(newHabit)
                }
                .transition(.scale)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showingAddHabit)
        .tint(.black)
    }
}

#Preview {
    CalendarView()
}
