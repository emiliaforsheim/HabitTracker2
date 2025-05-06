//
//  RegisterView.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    var onRegisterSuccess: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Coral"), Color("Purple"), Color("Blue")]),
                    startPoint: .top,
                    endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Image("Logga")
                    .resizable()
                    .frame(width: 300, height: 200)
                
                VStack {
                    Text("Create Account")
                        .font(.largeTitle)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                }
                
                VStack {
                    CustomTextField(text: $viewModel.name, placeHolder: "Name", image: "person")
                    
                    CustomTextField(text: $viewModel.email, placeHolder: "Email", image: "envelope")
                    
                    CustomTextField(text: $viewModel.password, placeHolder: "Password", image: "lock", isSecure: true)
                    
                    CustomTextField(text: $viewModel.confirmPassword, placeHolder: "Confirm Password", image: "lock", isSecure: true)
                    
                    CustomButton(label: "Register") {
                        viewModel.register { success in
                            if success {
                                onRegisterSuccess()
                            }
                        }
                    }
                    
                }
                .padding(30)
                
                
            }
        }
    }
}

#Preview {
    RegisterView(onRegisterSuccess: {})
}
