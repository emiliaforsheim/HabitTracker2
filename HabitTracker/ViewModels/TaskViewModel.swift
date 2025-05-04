//
//  TaskViewModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-05-02.
//

//
//  TaskViewModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-05-02.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class TaskViewModel: ObservableObject {
    @Published var isExpanded = false
    @Published var rotate = false
    @Published var subtaskStates: [UUID: Bool] = [:]
    private(set) var task: HabitModel
    var selectedDate: Date {
        didSet {
            loadSubtaskStates(from: task)
        }
    }

    private var dateKey: String {
        DateFormatter.taskDateFormatter.string(from: selectedDate)
    }

    init(task: HabitModel, selectedDate: Date) {
        self.selectedDate = selectedDate
        self.task = task
        self.loadSubtaskStates(from: task)
    }

    var completionPercentage: Double {
        guard !subtaskStates.isEmpty else { return 0 }
        let completed = subtaskStates.values.filter { $0 }.count
        return Double(completed) / Double(subtaskStates.count)
    }

    var isCompletedToday: Bool {
        completionPercentage == 1.0
    }

    var gradient: LinearGradient {
        let baseColor = task.color
        return LinearGradient(
            colors: isCompletedToday
                ? [Color("TaskYellow"), Color("TaskGreen")]
                : [baseColor, baseColor.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    func toggleSubtask(_ id: UUID, in task: Binding<HabitModel>) {
        subtaskStates[id]?.toggle()
        saveSubtaskStates(to: task)
        updateMainCompletion(for: task)
    }

    func isSubtaskCompleted(_ id: UUID) -> Bool {
        subtaskStates[id] ?? false
    }

    func loadSubtaskStates(from task: HabitModel) {
        guard let all = task.subtaskCompletionByDate?[dateKey] else {
            subtaskStates = task.subtasks.reduce(into: [:]) { $0[$1.id] = false }
            return
        }
        subtaskStates = all
    }

    func saveSubtaskStates(to task: Binding<HabitModel>) {
        if task.wrappedValue.subtaskCompletionByDate == nil {
            task.wrappedValue.subtaskCompletionByDate = [:]
        }
        task.wrappedValue.subtaskCompletionByDate?[dateKey] = subtaskStates
    }

    func updateMainCompletion(for task: Binding<HabitModel>) {
        let allComplete = subtaskStates.values.allSatisfy { $0 }
        if task.wrappedValue.completionByDate == nil {
            task.wrappedValue.completionByDate = [:]
        }
        task.wrappedValue.completionByDate?[dateKey] = allComplete

        DispatchQueue.main.async {
            self.rotate = allComplete
        }

        recalculateStreak(for: task)
        saveTask(task.wrappedValue)
    }

    func toggleCompletion(for task: Binding<HabitModel>) {
        let newState = !(task.wrappedValue.completionByDate?[dateKey] ?? false)

        if task.wrappedValue.completionByDate == nil {
            task.wrappedValue.completionByDate = [:]
        }
        task.wrappedValue.completionByDate?[dateKey] = newState

        // Mark all subtasks as complete or incomplete
        subtaskStates = subtaskStates.mapValues { _ in newState }
        saveSubtaskStates(to: task)

        DispatchQueue.main.async {
            self.rotate = newState
            //Self.ObjectWillChangePublisher().send()
        }

        recalculateStreak(for: task)
        saveTask(task.wrappedValue)
    }

    func recalculateStreak(for task: Binding<HabitModel>) {
        let completionMap = task.wrappedValue.completionByDate ?? [:]

        var streak = 0
        var currentDate = selectedDate

        while true {
            let key = DateFormatter.taskDateFormatter.string(from: currentDate)
            guard completionMap[key] == true else { break }
            streak += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }

        task.wrappedValue.currentStreak = streak
    }

    func formatted(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    private func saveTask(_ task: HabitModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let data = try Firestore.Encoder().encode(task)
            Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("habits")
                .document(task.id.uuidString)
                .setData(data, merge: true)
        } catch {
            print("❌ Failed to save task: \(error)")
        }
    }
}
