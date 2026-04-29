//
//  ViewModel.swift
//  employeePrediction
//
//  Created by prit on 27/04/26.
//

import Foundation
import Combine
// MARK: - View Model

@MainActor
final class PredictionViewModel: ObservableObject {
    @Published var averageMonthlyHours: String = ""
    @Published var numberProject: String = ""
    @Published var lastEvaluation: String = ""
    @Published var timeSpendCompany: String = ""

    @Published var predictionResult: PredictionResult? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showResult: Bool = false

    var isFormValid: Bool {
        !averageMonthlyHours.isEmpty &&
        !numberProject.isEmpty &&
        !lastEvaluation.isEmpty &&
        !timeSpendCompany.isEmpty
    }

    func predict() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields before predicting."
            return
        }

        guard let hours = Double(averageMonthlyHours),
              let projects = Int(numberProject),
              let evaluation = Double(lastEvaluation),
              let tenure = Int(timeSpendCompany) else {
            errorMessage = "Please enter valid numeric values."
            return
        }

        guard (0...300).contains(hours) else {
            errorMessage = "Monthly hours must be between 0 and 300."
            return
        }
        guard (0.0...1.0).contains(evaluation) else {
            errorMessage = "Last evaluation must be between 0.0 and 1.0."
            return
        }

        errorMessage = nil
        isLoading = true
        showResult = false

        defer { isLoading = false }
        
        var components = URLComponents(string: "https://employeepredictionmlmodel.onrender.com/predict")!

        guard var components = URLComponents(string: baseURLEndpoint) else {
            errorMessage = "Invalid server URL."
            return
        }

        components.queryItems = [
            URLQueryItem(name: "average_montly_hours", value: "\(Int(hours))"),
            URLQueryItem(name: "number_project",       value: "\(projects)"),
            URLQueryItem(name: "last_evaluation",      value: "\(evaluation)"),
            URLQueryItem(name: "time_spend_company",   value: "\(tenure)")
        ]

        guard let url = components.url else {
            errorMessage = "Failed to construct request URL."
            return
        }

        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 60
            let (data, response) = try await URLSession(configuration: config).data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                errorMessage = "Server error (HTTP \(httpResponse.statusCode))."
                return
            }

            let decoded = try JSONDecoder().decode(PredictionResponse.self, from: data)
            predictionResult = decoded.prediction
            showResult = true
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection."
            case .cannotConnectToHost, .timedOut:
                errorMessage = "Cannot reach the server. Is it running on localhost:8000?"
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } catch {
            errorMessage = "Failed to decode response: \(error.localizedDescription)"
        }
    }

    func reset() {
        averageMonthlyHours = ""
        numberProject = ""
        lastEvaluation = ""
        timeSpendCompany = ""
        predictionResult = nil
        errorMessage = nil
        showResult = false
    }
}
