//
//  TaskView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI

struct TaskView: View {
    @Binding var task: HabitModel
    var selectedDate: Date

    @StateObject private var viewModel: TaskViewModel

    init(task: Binding<HabitModel>, selectedDate: Date) {
        _task = task
        self.selectedDate = selectedDate
        _viewModel = StateObject(wrappedValue: TaskViewModel(task: task.wrappedValue, selectedDate: selectedDate))
    }

    var body: some View {
        VStack {
            ZStack {
                // Card background with animation
                RoundedRectangle(cornerRadius: 25)
                    .fill(viewModel.gradient)
                    .shadow(radius: 4)
                    .rotation3DEffect(.degrees(viewModel.rotate ? 180 : 0), axis: (x: 1, y: 0, z: 0))

                cardView()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .animation(.easeInOut(duration: 0.8), value: viewModel.rotate)
        }
        .onAppear {
            viewModel.task = task
            viewModel.selectedDate = selectedDate
            viewModel.loadSubtaskStates(from: task)
        }
        .onChange(of: task, initial: false) { oldTask, newTask in
            viewModel.task = newTask
        }
        .onChange(of: selectedDate, initial: false) {
            viewModel.selectedDate = selectedDate
            viewModel.loadSubtaskStates(from: task)
        }
    }

    // MARK: UI for habit card
    private func cardView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Completion toggle button
                Button(action: {
                    viewModel.toggleCompletion(for: $task)
                }) {
                    Image(systemName: viewModel.isCompletedToday ? "checkmark.circle.fill" : "checkmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }

                Text(task.name)
                    .foregroundColor(.black)
                    .font(.headline)

                Spacer()

                // Circular progress based on subtask completion
                CircularProgressView(progress: viewModel.completionPercentage)

                // Current streak
                ZStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.yellow)
                    Text("\(task.currentStreak)")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                }

                // Expand//collapse button for extra info
                Button(action: {
                    withAnimation {
                        viewModel.isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(viewModel.isExpanded ? 180 : 0))
                        .foregroundColor(.white)
                }
            }

            // MARK: Expanded view content
            if viewModel.isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.note)
                        .foregroundColor(.black)
                        .font(.subheadline)

                    // Show start date
                    Text("Start: \(viewModel.formatted(task.startDate))")
                        .foregroundColor(.black)
                        .font(.footnote)

                    // Show end date if exists
                    if let end = task.endDate {
                        Text("End: \(viewModel.formatted(end))")
                            .foregroundColor(.black)
                            .font(.footnote)
                    } else {
                        Text("Always")
                            .foregroundColor(.black)
                            .font(.footnote)
                    }

                    // Show subtask
                    if !task.subtasks.isEmpty {
                        Divider().padding(.vertical, 5)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(task.subtasks) { subtask in
                                HStack {
                                    // Toggle subtask completion
                                    Button(action: {
                                        viewModel.toggleSubtask(subtask.id, in: $task)
                                    }) {
                                        Image(systemName: viewModel.isSubtaskCompleted(subtask.id) ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(.black)
                                    }
                                    Text(subtask.title)
                                        .foregroundStyle(.black)
                                        .strikethrough(viewModel.isSubtaskCompleted(subtask.id))
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// Helper dateformatter
extension DateFormatter {
    static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
// MARK: View showing circular progress as percentage
struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(progress == 1.0 ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 10))
                .foregroundColor(.black)
        }
        .frame(width: 30, height: 30)
    }
}

// Preview
struct TaskViewPreviewWrapper: View {
    @State private var task = HabitModel(
        name: "Exempel Task",
        note: "Detta är en exempelbeskrivning.",
        colorHex: "#3498DB",
        subtasks: [
            .init(title: "Del 1", isCompleted: false),
            .init(title: "Del 2", isCompleted: false),
            .init(title: "Del 3", isCompleted: false)
        ],
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
        completionByDate: [:],
        currentStreak: 0,
        lastCompletedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())
    )

    var body: some View {
        TaskView(task: $task, selectedDate: Date())
    }
}

#Preview {
    TaskViewPreviewWrapper()
}
