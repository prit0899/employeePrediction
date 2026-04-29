//
//  Untitled.swift
//  employeePrediction
//
//  Created by prit on 29/04/26.
//

import SwiftUI

// MARK: - Result View
struct ResultView: View {
    let result: PredictionResponse
    @Environment(\.dismiss) var dismiss
 
    var isHighRisk: Bool { result.prediction.prediction == 1 }
    var probabilityPercent: Int { Int(result.prediction.probability * 100) }
 
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: isHighRisk
                    ? [Color(hex: "#3a1c71"), Color(hex: "#d76d77"), Color(hex: "#ffaf7b")]
                    : [Color(hex: "#134e5e"), Color(hex: "#71b280")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
 
            VStack(spacing: 32) {
                Spacer()
 
                // Risk Icon
                Text(isHighRisk ? "🔴" : "🟢")
                    .font(.system(size: 80))
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: true)
 
                // Risk Label
                Text(isHighRisk ? "HIGH RISK" : "LOW RISK")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
 
                // Probability Card
                VStack(spacing: 12) {
                    Text("Probability of Leaving")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
 
                    Text("\(probabilityPercent)%")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
 
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.2))
                                .frame(height: 12)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .frame(width: geo.size.width * result.prediction.probability, height: 12)
                        }
                    }
                    .frame(height: 12)
                    .padding(.horizontal, 8)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 32)
 
                // Description
                Text(isHighRisk
                    ? "This employee shows signs of disengagement. HR intervention recommended."
                    : "This employee appears stable and engaged with the organization.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
 
                Spacer()
 
                // Back Button
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Check Another Employee")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
