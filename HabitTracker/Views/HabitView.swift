//
//  ContentView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
// hej

import SwiftUI

struct HabitView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var currentWeekOffset = 0
    @State private var selectedDate = Date()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("Coral"), Color("Purple"), Color("Blue")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                weekHeader
                    .padding(.top, 2)
                    .padding(.horizontal)

                ScrollView {
                    let habits = viewModel.habitsForDate(selectedDate)
                    
                    if habits.isEmpty {
                        Text("No habits for \(formattedDate(selectedDate))")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        VStack(spacing: -5) {
                            ForEach(habits) { habit in
                                if let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) {
                                    TaskView(task: $viewModel.habits[index], selectedDate: selectedDate)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            viewModel.loadHabits()
        }
    }

    private var weekHeader: some View {
        HStack {
            Button(action: {
                currentWeekOffset -= 1
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 12) {
                ForEach(currentWeekDates(), id: \.self) { date in
                    Button(action: {
                        selectedDate = date
                    }) {
                        VStack {
                            Text(shortDayName(from: date))
                                .font(.caption)
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.headline)
                        }
                        .frame(width: 40, height: 60)
                        .background(
                            ZStack {
                                if Calendar.current.isDateInToday(date) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("Purple").opacity(0.5))
                                }

                                if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.2))
                                }
                            }
                        )
                        .tint(.black)
                    }
                }
                .padding(.horizontal, -1.5)
            }

            Spacer()

            Button(action: {
                currentWeekOffset += 1
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }

    private func currentWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func shortDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "E"
        return formatter.string(from: date).capitalized
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}

#Preview {
    HabitView(viewModel: CalendarViewModel())
}
