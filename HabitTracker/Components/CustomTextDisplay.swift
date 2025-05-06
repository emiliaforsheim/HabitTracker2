//
//  CustomTextDisplay.swift
//  HabitTracker
//
//  Created by Emilia Forsheim on 2025-05-05.
//

import Foundation
import SwiftUI

struct CustomTextDisplay: View {
    var text: String
    var placeholder: String
    var image: String

    var body: some View {
        HStack {
            Image(systemName: image)
            Text(text)
                .font(.title3)
            Spacer()
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 8)
    }
}
