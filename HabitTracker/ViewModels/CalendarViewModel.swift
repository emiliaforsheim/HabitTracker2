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
            print("🚫 Ingen användare inloggad")
            return
        }

        print("📡 Hämtar habits för userID: \(userId)")

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("habits")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Fel vid hämtning: \(error.localizedDescription)")
                    return
                }

                let documents = snapshot?.documents ?? []

                let fetchedHabits: [HabitModel] = documents.compactMap { doc in
                    do {
                        return try doc.data(as: HabitModel.self)
                    } catch {
                        print("❌ Kunde inte decoda habit: \(error)")
                        return nil
                    }
                }

                DispatchQueue.main.async {
                    self.habits = fetchedHabits
                    print("✅ Hämtade \(fetchedHabits.count) habits")
                }
            }
    }

    func addHabit(_ habit: HabitModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            try Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("habits")
                .document(habit.id.uuidString) // OBS! Använd UUID-sträng som ID
                .setData(from: habit)

            // Uppdatera lokalt direkt
            DispatchQueue.main.async {
                self.habits.append(habit)
            }
        } catch {
            print("❌ Failed to save habit: \(error.localizedDescription)")
        }
    }

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
