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
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("Coral"), Color("Purple"), Color("Blue")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal)

                let habitsForSelectedDate = viewModel.habitsForDate(selectedDate)

                if habitsForSelectedDate.isEmpty {
                    Text("No habits for this date.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.headline)
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(habitsForSelectedDate) { habit in
                                if let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) {
                                    TaskView(task: $viewModel.habits[index], selectedDate: selectedDate)
                                }
                            }
                        }
                        .padding(.horizontal, -5)
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
                            .background(Color.white.opacity(0.7))
                            .foregroundStyle(.black)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    }
                    .padding()
                }
            }

            if showingAddHabit {
                Color.black.opacity(0.3).ignoresSafeArea()

                AddHabit(showPopup: $showingAddHabit, selectedStartDate: selectedDate) { newHabit in
                    viewModel.addHabit(newHabit)
                }
                .transition(.scale)
                .zIndex(1)
            }
        }
        .onAppear {
            viewModel.loadHabits()
        }
        .animation(.easeInOut, value: showingAddHabit)
        .tint(.black)
    }
}

#Preview {
    CalendarView(viewModel: CalendarViewModel())
}
