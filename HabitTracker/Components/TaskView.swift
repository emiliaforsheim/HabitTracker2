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
            viewModel.loadSubtaskStates(from: task)
        }
        .onChange(of: selectedDate) {
            viewModel.selectedDate = selectedDate
            viewModel.loadSubtaskStates(from: task)
        }
    }

    private func cardView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
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

                CircularProgressView(progress: viewModel.completionPercentage)

                ZStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.yellow)
                    Text("\(task.currentStreak)")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                }

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

            if viewModel.isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.note)
                        .foregroundColor(.black)
                        .font(.subheadline)

                    Text("Start: \(viewModel.formatted(task.startDate))")
                        .foregroundColor(.black)
                        .font(.footnote)

                    if let end = task.endDate {
                        Text("Slutar: \(viewModel.formatted(end))")
                            .foregroundColor(.black)
                            .font(.footnote)
                    } else {
                        Text("Varar för alltid")
                            .foregroundColor(.black)
                            .font(.footnote)
                    }

                    if !task.subtasks.isEmpty {
                        Divider().padding(.vertical, 5)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(task.subtasks) { subtask in
                                HStack {
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

extension DateFormatter {
    static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

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
