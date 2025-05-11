//
//  CalendarViewModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class CalendarViewModel: ObservableObject {
    @Published var habits: [HabitModel] = []

    func loadHabits() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No User logged in")
            return
        }

        print("Fetching habits for userID: \(userId)")

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("habits")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching habits: \(error.localizedDescription)")
                    return
                }

                let documents = snapshot?.documents ?? []

                let fetchedHabits: [HabitModel] = documents.compactMap { doc in
                    do {
                        return try doc.data(as: HabitModel.self)
                    } catch {
                        print("Failed to decode habit: \(error)")
                        return nil
                    }
                }

                DispatchQueue.main.async {
                    self.habits = fetchedHabits
                    print("Loaded \(fetchedHabits.count) habits")
                }
            }
    }

    // Saves a new habit to Firestore and updates local state
    func addHabit(_ habit: HabitModel) {
        // Ensure user i logged in
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            // Store habit in firestore
            try Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("habits")
                .document(habit.id.uuidString)
                .setData(from: habit)

            // Append new habit locally to update the UI immediately
            DispatchQueue.main.async {
                self.habits.append(habit)
            }
        } catch {
            print("Failed to save habit: \(error.localizedDescription)")
        }
    }

    // Returns the list of habits that are active on a given date
    func habitsForDate(_ date: Date) -> [HabitModel] {
        let selected = Calendar.current.startOfDay(for: date)

        return habits.filter { habit in
            let start = Calendar.current.startOfDay(for: habit.startDate)
            let end = habit.endDate != nil ? Calendar.current.startOfDay(for: habit.endDate!) : nil

            if let end = end {
                return selected >= start && selected <= end
            } else {
                return selected >= start
            }
        }
    }
}
