//
//  LoginView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI
import AuthenticationServices

enum AuthRoute: Hashable {
    case register
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var path = NavigationPath()
    
    var onLoginSuccess: () -> Void
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Coral"), Color("Purple"), Color("Blue")]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                VStack {
                    Image("Logga")
                        .resizable()
                        .frame(width: 300, height: 200)
                        .padding(.top, -100)
                        .padding(.bottom, 10)
                    
                    VStack {
                        Text("Habit Tracker")
                            .font(.largeTitle)
                            .padding(.bottom, 50)
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundStyle(.red)
                        }
                        
                        CustomTextField(text: $viewModel.email, placeHolder: "Email", image: "envelope")
                        
                        CustomTextField(text: $viewModel.password, placeHolder: "Password", image: "lock", isSecure: true)
                            .padding(.bottom)
                        
                        CustomButton(label: "Login") {
                            viewModel.login { success in
                                if success {
                                    onLoginSuccess()
                                }
                            }
                        }
                    }
                    .padding(20)
                    
                    HStack {
                        VStack {Divider()}
                        Text("Or")
                        VStack {Divider()}
                    }
                    
                    VStack(spacing: 10) {
                        CustomButton(label: "Sign up with email", iconName: "envelope") {
                            path.append(AuthRoute.register)
                        }
                    }
                    .padding()
                    .tint(.black)
                }
                .padding()
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterView {
                        onLoginSuccess()
                    }
                }
            }
        }
        .tint(.black)
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
