//
//  CustomTextField.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-04-30.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeHolder: String
    var image: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: image)
            if isSecure {
                SecureField(placeHolder, text: $text)
            } else {
                TextField(placeHolder, text: $text)
            }
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 8)
    }
}
