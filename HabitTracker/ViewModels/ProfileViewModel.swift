//
//  ProfileViewModel.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel?

    func loadUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let docRef = Firestore.firestore().collection("users").document(userId)
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch user: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No user data found")
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let fetchedUser = try JSONDecoder().decode(UserModel.self, from: jsonData)
                DispatchQueue.main.async {
                    self.user = fetchedUser
                }
            } catch {
                print("Failed to decode user: \(error.localizedDescription)")
            }
        }
    }
}
