// Models.swift
import Foundation

// MARK: - Models

struct PredictionResult: Decodable {
    let prediction: Int
    let probability: Double
}

struct PredictionResponse: Decodable {
    let prediction: PredictionResult
}
