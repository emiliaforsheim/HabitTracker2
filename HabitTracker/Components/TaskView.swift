//
//  TaskView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI

struct TaskView: View {
    var task: HabitModel

    @State private var isCompleted = false
    @State private var rotate = false
    @State private var isExpanded = false
    @State private var subtaskStates: [UUID: Bool] = [:]

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: isCompleted
                                ? [Color("TaskYellow"), Color("TaskGreen")]
                                : [task.color, task.color.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 370, height: isExpanded ? nil : 70)
                    .rotation3DEffect(
                        .degrees(rotate ? 180 : 0),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .animation(.easeInOut(duration: 1.5), value: rotate)
                    .clipped()

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Button(action: {
                            rotate.toggle()
                            isCompleted.toggle()
                        }) {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }

                        Text(task.name)
                            .foregroundColor(.black)
                            .font(.headline)

                        Spacer()
                        
                        CircularProgressView(progress: completionPercentage())

                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .foregroundColor(.white)
                        }
                    }

                    if isExpanded {
                        Text(task.note)
                            .foregroundColor(.black)
                            .font(.subheadline)
                            .transition(.opacity)

                        Text("Start: \(formattedDate(task.startDate))")
                            .foregroundColor(.black)
                            .font(.footnote)

                        if let end = task.endDate {
                            Text("Slutar: \(formattedDate(end))")
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
                                            subtaskStates[subtask.id]?.toggle()
                                            checkIfAllSubtasksCompleted()
                                        }) {
                                            Image(systemName: subtaskStates[subtask.id] == true ? "checkmark.circle.fill" : "checkmark.circle")
                                                .foregroundStyle(.black)
                                        }
                                        Text(subtask.title)
                                            .foregroundStyle(.black)
                                            .strikethrough(subtaskStates[subtask.id] == true)
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding(.vertical, 5)
        .onAppear {
            for subtask in task.subtasks {
                subtaskStates[subtask.id] = subtask.isCompleted
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    func completionPercentage() -> Double {
        guard !task.subtasks.isEmpty else { return 0 }
        let completed = subtaskStates.values.filter { $0 }.count
        return Double(completed) / Double(task.subtasks.count)
    }
    func checkIfAllSubtasksCompleted() {
        guard !subtaskStates.isEmpty else { return }
        let allCompleted = subtaskStates.values.allSatisfy { $0 }
        withAnimation {
            isCompleted = allCompleted
            rotate = allCompleted
        }
    }
}

struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(progress == 1.0 ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 10))
                .foregroundColor(.black)
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    TaskView(task: HabitModel(
        name: "Exempel Task",
        note: "Detta är en exempelbeskrivning.",
        color: .blue,
        subtasks: [],
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())
    ))
}
