//
//  ProfileView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-29.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    var onLogout: () -> Void

    init(viewModel: CalendarViewModel, profileViewModel: ProfileViewModel = ProfileViewModel(), onLogout: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._profileViewModel = StateObject(wrappedValue: profileViewModel)
        self.onLogout = onLogout
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [Color("Coral"), Color("Purple"), Color("Blue")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: {
                        logOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.4)))
                            .shadow(radius: 3)
                    }
                    .padding([.top, .trailing], 1)
                }

                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .padding(.bottom)

                if let user = profileViewModel.user {
                    CustomTextDisplay(text: user.name, placeholder: "Name", image: "person")
                    CustomTextDisplay(text: user.email, placeholder: "Email", image: "envelope")

                    VStack {
                        Text("Current Streaks")
                            .font(.title3)
                            .bold()
                            .padding(.top, 10)

                        Divider().background(.white.opacity(0.5))

                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                                ForEach(viewModel.habits) { habit in
                                    streakCard(habit: habit)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal)

                    Text("Joined: \(formattedDate(from: user.joined))")
                        .font(.footnote)
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.bottom, 10)
                } else {
                    ProgressView().padding()
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        .onAppear {
            profileViewModel.loadUser()
        }
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
            onLogout()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    private func streakCard(habit: HabitModel) -> some View {
        VStack(spacing: 3) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.yellow)

            Text("\(habit.currentStreak)")
                .font(.title3.bold())
                .foregroundColor(.white)

            Text(habit.name)
                .font(.caption2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100, height: 100)
        .background(habit.color.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 4)
    }
    
//    private func streakCard(habit: HabitModel) -> some View {
//        VStack(spacing: 6) {
//            ZStack {
//                Image(systemName: "star.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 80, height: 80)
//                    .foregroundColor(habit.color)
//
//                Text("\(habit.currentStreak)")
//                    .font(.headline.bold())
//                    .foregroundColor(.white)
//            }
//
//            Text(habit.name)
//                .font(.caption2)
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
//        }
//        .frame(width: 100)
//    }

    private func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    let mockHabits = [
        HabitModel(
            name: "Springa",
            note: "varje morgon",
            colorHex: "#FF6F61",
            subtasks: [],
            startDate: Date(),
            endDate: nil,
            completionByDate: [:],
            currentStreak: 5,
            lastCompletedDate: Date()
        ),
        HabitModel(
            name: "Träna",
            note: "Gym 3 dagar i veckan",
            colorHex: "#6A5ACD",
            subtasks: [],
            startDate: Date(),
            endDate: nil,
            completionByDate: [:],
            currentStreak: 12,
            lastCompletedDate: Date()
        )
    ]

    let mockViewModel = CalendarViewModel()
    mockViewModel.habits = mockHabits

    let mockProfileViewModel = ProfileViewModel()
    mockProfileViewModel.user = UserModel(
        id: "123",
        name: "exempel",
        email: "exempel@exemple.com",
        joined: Date().timeIntervalSince1970
    )

    return ProfileView(viewModel: mockViewModel, profileViewModel: mockProfileViewModel, onLogout: {
        print("logout")
    })
}
