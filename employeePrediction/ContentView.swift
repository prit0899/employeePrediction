//
//  ContentView.swift
//  employeePrediction
//
//  Created by prit on 27/04/26.
//

import SwiftUI




// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var viewModel = PredictionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    inputSection
                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }
                    predictButton
                    if viewModel.showResult, let result = viewModel.predictionResult {
                        ResultCard(result: result, onReset: viewModel.reset)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Employee Prediction")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "person.fill.checkmark")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }
            Text("Will this employee leave?")
                .font(.title2.bold())
            Text("Enter the employee's metrics below to predict attrition risk using our ML model.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: Input Section

    private var inputSection: some View {
        VStack(spacing: 0) {
            InputRow(
                icon: "clock.fill",
                iconColor: .orange,
                label: "Avg Monthly Hours",
                hint: "e.g. 160",
                text: $viewModel.averageMonthlyHours,
                keyboardType: .numberPad
            )
            Divider().padding(.leading, 56)

            InputRow(
                icon: "folder.fill",
                iconColor: .blue,
                label: "Number of Projects",
                hint: "e.g. 5",
                text: $viewModel.numberProject,
                keyboardType: .numberPad
            )
            Divider().padding(.leading, 56)

            InputRow(
                icon: "star.fill",
                iconColor: .yellow,
                label: "Last Evaluation",
                hint: "0.0 – 1.0",
                text: $viewModel.lastEvaluation,
                keyboardType: .decimalPad
            )
            Divider().padding(.leading, 56)

            InputRow(
                icon: "building.2.fill",
                iconColor: .green,
                label: "Years at Company",
                hint: "e.g. 3",
                text: $viewModel.timeSpendCompany,
                keyboardType: .numberPad
            )
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(14)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: Predict Button

    private var predictButton: some View {
        Button {
            Task { await viewModel.predict() }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(viewModel.isLoading ? "Predicting…" : "Predict Attrition")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.isFormValid
                    ? Color.blue
                    : Color.blue.opacity(0.4),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .foregroundStyle(.white)
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
    }
}

// MARK: - Input Row Component

struct InputRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let hint: String
    @Binding var text: String
    let keyboardType: UIKeyboardType

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
                TextField(hint, text: $text)
                    .keyboardType(keyboardType)
                    .font(.body)
            }

            Spacer()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Result Card

struct ResultCard: View {
    let result: PredictionResult
    let onReset: () -> Void

    private var willLeave: Bool { result.prediction == 1 }
    private var probability: Double { result.probability }
    private var riskLevel: String {
        switch probability {
        case 0.75...: return "High Risk"
        case 0.50...: return "Moderate Risk"
        default:      return "Low Risk"
        }
    }
    private var riskColor: Color {
        switch probability {
        case 0.75...: return .red
        case 0.50...: return .orange
        default:      return .green
        }
    }

    var body: some View {
        VStack(spacing: 20) {

            // Verdict badge
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(riskColor.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Image(systemName: willLeave ? "person.fill.xmark" : "person.fill.checkmark")
                        .font(.system(size: 30))
                        .foregroundStyle(riskColor)
                }
                Text(willLeave ? "Likely to Leave" : "Likely to Stay")
                    .font(.title3.bold())
                Text(riskLevel)
                    .font(.caption.uppercaseSmallCaps())
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(riskColor, in: Capsule())
            }

            Divider()

            // Probability meter
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Probability of Leaving")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(String(format: "%.1f%%", probability * 100))
                        .font(.subheadline.bold())
                        .foregroundStyle(riskColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemFill))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [riskColor.opacity(0.7), riskColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * probability, height: 10)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: probability)
                    }
                }
                .frame(height: 10)
            }

            Divider()

            // Reset button
            Button(action: onReset) {
                Label("New Prediction", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
