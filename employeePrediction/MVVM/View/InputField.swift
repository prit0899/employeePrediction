//
//  InputField.swift
//  employeePrediction
//
//  Created by prit on 29/04/26.
//

import SwiftUI
// MARK: - Reusable Input Field
struct InputField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
 
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.white)
                .font(.system(size: 16, design: .rounded))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        }
    }
}
