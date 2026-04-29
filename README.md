# 📱 Employee Attrition Predictor — iOS App

An iOS application that predicts whether an employee is at risk of leaving an organization, powered by a **Python ML backend** via REST API.

> 🔗 **ML Backend Repo:** [employeePredictionMLModel](https://github.com/prit0899/employeePredictionMLModel)

---

## 📸 What It Does

- User enters employee details (evaluation score, projects, hours, tenure)
- App calls a **FastAPI ML backend** in real time
- Displays prediction: **High Risk 🔴** or **Low Risk 🟢** with probability score

---

## 🏗️ Architecture

```
iOS App (Swift)
     ↓  URLSession HTTP Request
FastAPI Server (Python)
     ↓  Loads saved model
Logistic Regression Model (scikit-learn)
     ↓  Returns JSON
iOS App displays result
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift |
| UI | SwiftUI |
| Networking | URLSession |
| Data Parsing | Codable / JSONDecoder |
| Backend | FastAPI (Python) |
| ML Model | Logistic Regression (scikit-learn) |

---

## 📋 Input Fields

| Field | Description | Example |
|---|---|---|
| Last Evaluation | Performance score (0.0 – 1.0) | 0.85 |
| Number of Projects | Active projects assigned | 5 |
| Average Monthly Hours | Monthly working hours | 220 |
| Time at Company | Years in organization | 3 |

---

## 📡 API Integration

The app communicates with the ML backend via a GET request:

```
GET http://<server>/predict?last_evaluation=0.8&number_project=5&average_montly_hours=220&time_spend_company=3
```

**Response:**
```json
{
  "prediction": "High Risk",
  "probability": 0.83
}
```

**Swift Codable model:**
```swift
struct PredictionResponse: Codable {
    let prediction: String
    let probability: Double
}
```

---

## 🚀 How to Run

**Prerequisites:**
- Xcode 15+
- iOS 16+
- ML backend running (see [backend repo](https://github.com/prit0899/employeePredictionMLModel))

**Steps:**
1. Clone this repo
```bash
git clone https://github.com/prit0899/employeePrediction.git
```
2. Open `employeePrediction.xcodeproj` in Xcode
3. Start the FastAPI backend locally:
```bash
uvicorn main:app --reload
```
4. Run the app on simulator or device
5. Enter employee details and tap **Predict**

---

## 🔗 Related

- **ML Model + FastAPI Backend:** [employeePredictionMLModel](https://github.com/prit0899/employeePredictionMLModel)
- **Dataset:** [Kaggle HR Dataset](https://www.kaggle.com/datasets/liujiaqi/hr-comma-sepcsv)

---

## 👨‍💻 Author

**Prit** — 6 years iOS Developer, expanding into AI Product Engineering.

This project demonstrates end-to-end ownership: ML model training → API deployment → mobile client — the core skill set for **AI Product Engineer** roles.
