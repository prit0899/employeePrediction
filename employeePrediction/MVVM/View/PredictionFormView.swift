//
//  PredictionFormView.swift
//  employeePrediction
//
//  Created by prit on 29/04/26.
//

import SwiftUI

// MARK: - Input Form View
struct PredictionFormView: View {
    @State private var lastEvaluation: String = ""
    @State private var numberProject: String = ""
    @State private var averageMonthlyHours: String = ""
    @State private var timeSpendCompany: String = ""
    @State private var isLoading = false
    @State private var predictionResult: PredictionResponse? = nil
    @State private var showResult = false
    @State private var errorMessage: String? = nil
 
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#0F2027"), Color(hex: "#203A43"), Color(hex: "#2C5364")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
 
                ScrollView {
                    VStack(spacing: 28) {
 
                        // Header
                        VStack(spacing: 8) {
                            Text("👥")
                                .font(.system(size: 52))
                            Text("Attrition Predictor")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Predict employee retention risk")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
 
                        // Input Card
                        VStack(spacing: 20) {
                            InputField(
                                icon: "star.fill",
                                title: "Last Evaluation",
                                placeholder: "0.0 – 1.0  (e.g. 0.85)",
                                text: $lastEvaluation
                            )
                            InputField(
                                icon: "folder.fill",
                                title: "Number of Projects",
                                placeholder: "e.g. 5",
                                text: $numberProject
                            )
                            InputField(
                                icon: "clock.fill",
                                title: "Avg Monthly Hours",
                                placeholder: "e.g. 220",
                                text: $averageMonthlyHours
                            )
                            InputField(
                                icon: "calendar",
                                title: "Years at Company",
                                placeholder: "e.g. 3",
                                text: $timeSpendCompany
                            )
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
 
                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red.opacity(0.9))
                                .font(.caption)
                                .padding(.horizontal)
                        }
 
                        // Predict Button
                        Button(action: predict) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#11998e"), Color(hex: "#38ef7d")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 56)
 
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Predict Risk")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .disabled(isLoading)
 
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $showResult) {
                if let result = predictionResult {
                    ResultView(result: result)
                }
            }
        }
    }
 
    // MARK: - API Call
    func predict() {
        errorMessage = nil
 
        guard
            let evaluation = Double(lastEvaluation),
            let projects = Int(numberProject),
            let hours = Double(averageMonthlyHours),
            let years = Double(timeSpendCompany)
        else {
            errorMessage = "Please fill all fields with valid numbers."
            return
        }
 
        guard evaluation >= 0 && evaluation <= 1 else {
            errorMessage = "Last Evaluation must be between 0.0 and 1.0"
            return
        }
 
        isLoading = true
 
        var components = URLComponents(string: "http://localhost:8000/predict")!
        components.queryItems = [
            URLQueryItem(name: "last_evaluation", value: "\(evaluation)"),
            URLQueryItem(name: "number_project", value: "\(projects)"),
            URLQueryItem(name: "average_montly_hours", value: "\(hours)"),
            URLQueryItem(name: "time_spend_company", value: "\(years)")
        ]
 
        guard let url = components.url else { return }
 
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
 
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
 
                guard let data = data else {
                    errorMessage = "No data received from server."
                    return
                }
 
                do {
                    let decoded = try JSONDecoder().decode(PredictionResponse.self, from: data)
                    predictionResult = decoded
                    showResult = true
                } catch {
                    errorMessage = "Could not read server response. Is the API running?"
                }
            }
        }.resume()
    }
}
