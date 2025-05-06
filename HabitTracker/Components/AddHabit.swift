//
//  AddHabit.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI

struct AddHabit: View {
    @Binding var showPopup: Bool
    var selectedStartDate: Date
    var onSave: (HabitModel) -> Void

    @State private var habitName: String = ""
    @State private var habitNote: String = ""
    @State private var selectedColor: Color = .white
    @State private var newSubTask: String = ""
    @State private var subtasks: [HabitModel.Subtask] = []

    @State private var habitDurationDays: Int = 1
    @State private var isForever: Bool = false

    var body: some View {
        let textColor: Color = selectedColor.isDarkColor ? .white : .black

        VStack(spacing: 20) {
            Text("New Habit")
                .font(.headline)
                .foregroundStyle(textColor)

            TextField("Title", text: $habitName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Description", text: $habitNote)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // MARK: Days or always
            Toggle("Always", isOn: $isForever)
                .foregroundStyle(textColor)

            if !isForever {
                HStack {
                    Text("Duration: \(habitDurationDays) days")
                        .foregroundStyle(textColor)
                    Spacer()
                    Stepper("", value: $habitDurationDays, in: 1...365)
                        .labelsHidden()
                }
            }

            // MARK: Subtask
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    TextField("Add Subtask", text: $newSubTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        if !newSubTask.isEmpty {
                            let subtask = HabitModel.Subtask(title: newSubTask, isCompleted: false)
                            subtasks.append(subtask)
                            newSubTask = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(textColor)
                    }
                }

                // Subtask list
                ForEach(subtasks) { subtask in
                    Text("• \(subtask.title)")
                        .foregroundStyle(textColor)
                        .font(.subheadline)
                }
            }

            // MARK: Colorpicker
            HStack {
                Text("Pick Color")
                    .foregroundStyle(textColor)
                Spacer()
                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
            }

            Divider()

            HStack {
                Button("Cancel") {
                    showPopup = false
                }
                .foregroundStyle(textColor)

                Spacer()

                Button("Save") {
                    // Calculate end date if not forever
                    let endDate = isForever
                        ? nil
                        : Calendar.current.date(byAdding: .day, value: habitDurationDays, to: selectedStartDate)

                    // Create and save the new habit
                    let newHabit = HabitModel(
                        name: habitName,
                        note: habitNote,
                        colorHex: selectedColor.toHex(),
                        subtasks: subtasks,
                        startDate: selectedStartDate,
                        endDate: endDate
                    )

                    onSave(newHabit)
                    showPopup = false
                }
                .foregroundStyle(textColor)
            }
        }
        .padding()
        .frame(width: 300)
        .background(selectedColor)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// Black or white text color
extension Color {
    var isDarkColor: Bool {
        let uiColor = UIColor(self)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white < 0.5
    }
}

#Preview {
    AddHabitPreviewWrapper()
}

struct AddHabitPreviewWrapper: View {
    @State private var showPopup = true

    var body: some View {
        AddHabit(showPopup: $showPopup, selectedStartDate: Date()) { habit in
            print("Habit sparad: \(habit.name)")
        }
    }
}
