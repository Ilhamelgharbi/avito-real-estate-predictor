# 🏠 Avito Real Estate Predictor

*A beginner-friendly machine learning app for predicting apartment prices in Morocco*

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.20+-red.svg)](https://streamlit.io/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-1.3+-orange.svg)](https://scikit-learn.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Table of Contents

- [🏠 Avito Real Estate Predictor](#-avito-real-estate-predictor)
  - [📋 Table of Contents](#-table-of-contents)
  - [🎯 What is This Project?](#-what-is-this-project)
  - [✨ Key Features](#-key-features)
  - [🚀 Quick Start Guide](#-quick-start-guide)
  - [📊 How to Use the App](#-how-to-use-the-app)
  - [🏗️ Project Structure](#️-project-structure)
  - [🤖 Technical Details](#-technical-details)
  - [🔧 API Reference](#-api-reference)
  - [📈 Model Performance](#-model-performance)
  - [🧪 Testing](#-testing)
  - [🚀 Deployment](#-deployment)
  - [🤝 Contributing](#-contributing)
  - [📄 License](#-license)

## 🎯 What is This Project?

**Avito Real Estate Predictor** is a smart web application that helps you estimate apartment prices in Morocco. Whether you're buying, selling, or just curious about real estate values, this tool uses machine learning to give you accurate price predictions based on:

- 🏙️ **Location**: 14 major Moroccan cities (Casablanca, Rabat, Marrakech, etc.)
- 📐 **Size**: Surface area, number of rooms and bathrooms
- 🛠️ **Features**: Equipment like elevator, balcony, parking, heating, etc.

**Perfect for beginners!** No coding experience needed - just follow the simple steps below to get started.

## ✨ Key Features

### 🤖 Smart Predictions
- **82.7% accuracy** using advanced machine learning
- **Real-time estimates** with confidence intervals
- **Price per square meter** calculations

### 🌍 Morocco-Focused
- **14 major cities** covered
- **Local market data** for accurate predictions
- **Arabic/French interface** elements

### 💻 Easy-to-Use Interface
- **Web-based app** - works in any browser
- **Tabbed design** - separate sections for predictions and analytics
- **Mobile-friendly** - responsive design

### 📊 Data Insights
- **Interactive charts** showing price distributions
- **City comparisons** and market analysis
- **Model performance** metrics and visualizations

## 🚀 Quick Start Guide

### Step 1: Check Your System

Make sure you have:
- **Python 3.8 or higher** (check by running `python --version` in terminal)
- **Internet connection** for downloading files
- **Web browser** (Chrome, Firefox, Safari, etc.)

*Don't have Python? Download it from [python.org](https://www.python.org/downloads/)*

### Step 2: Get the Project

**Option A: Download ZIP (Easiest)**
1. Go to the project repository
2. Click "Code" → "Download ZIP"
3. Extract the ZIP file to your computer
4. Open the extracted folder

**Option B: Using Git (Advanced)**
```bash
git clone https://github.com/Ilhamelgharbi/avito-real-estate-predictor.git
cd avito-real-estate-predictor
```

### Step 3: Install Everything

```bash
pip install -r requirements.txt
```

### Step 4: Run the App

**One-Click Start:**
```bash
# Windows:
start.bat

# Mac/Linux:
./start.sh
```

Your browser will open automatically at `http://localhost:8501`

### Step 5: Start Predicting!

1. Choose a city from the dropdown
2. Enter apartment details (size, rooms, etc.)
3. Select equipment features
4. Click "🔮 PRÉDIRE LE PRIX"
5. Get your instant price estimate!

## 📊 How to Use the App

### 🏠 Making Price Predictions

1. **Select City**: Pick from 14 Moroccan cities
2. **Enter Details**:
   - Surface area (20-500 m²)
   - Number of rooms (1-15)
   - Number of bathrooms (0-10)
3. **Choose Equipment**: Check boxes for features like:
   - Ascenseur (Elevator)
   - Balcon (Balcony)
   - Parking
   - Chauffage (Heating)
   - And more!

4. **Get Results**:
   - **Estimated Price** in Moroccan Dirhams (MAD)
   - **Price per m²** for comparison
   - **Confidence Range** (85%-115% of estimate)

### 📈 Exploring Analytics

Switch to the "📊 Modèle & Visualisations" tab to see:
- Price distribution charts
- City-by-city statistics
- Feature correlation analysis
- Model performance metrics

## 🏗️ Project Structure

```
avito-real-estate-predictor/
├── backend/                 # FastAPI server
│   ├── main.py             # API endpoints
│   └── __pycache__/
├── frontend/               # Streamlit web app
│   ├── app.py              # Main interface
│   └── __pycache__/
├── models/                 # ML model files
│   ├── best_model.pkl      # Trained model
│   ├── scaler.pkl          # Data scaler
│   └── metadata.json       # Model info
├── data/                   # Dataset files
│   ├── appartements-data-db.csv
│   └── processed/
├── visualizations/         # Charts and graphs
│   ├── city_statistics.png
│   ├── price_distribution.png
│   └── correlation_matrix.png
├── notebooks/              # Jupyter analysis
│   ├── saleshouses_ml_pipeline.ipynb
│   └── script.py
├── reports/                # Performance reports
└── requirements.txt        # Dependencies
```

## 🤖 Technical Details

### Machine Learning Model
- **Algorithm**: Gradient Boosting Regressor
- **Accuracy**: 82.7% R² score
- **Features**: 25+ engineered features
- **Training Data**: Moroccan real estate market data

### Technologies Used
- **Backend**: FastAPI (Python web framework)
- **Frontend**: Streamlit (Python web app framework)
- **ML**: scikit-learn, pandas, numpy
- **Visualization**: matplotlib, seaborn, plotly

### Data Processing
- **Outlier removal** using IQR method
- **Feature scaling** with StandardScaler
- **Categorical encoding** for cities and equipment
- **Feature engineering** (ratios, scores)

## 🔧 API Reference

### Base URL
```
http://localhost:8000
```

### Endpoints

#### `GET /`
Basic API information
```json
{
  "message": "Avito Real Estate Predictor API",
  "version": "1.0.0"
}
```

#### `GET /health`
Check if API is running
```json
{
  "status": "ok",
  "model_loaded": true,
  "scaler_loaded": true
}
```

#### `POST /predict`
Make a price prediction
```json
// Request
{
  "city": "Casablanca",
  "surface_area": 100.0,
  "nb_baths": 2,
  "total_rooms": 3,
  "equipment_list": ["Ascenseur", "Balcon", "Parking"]
}

// Response
{
  "predicted_price": 2500000.0,
  "price_per_m2": 25000.0,
  "confidence_interval": {
    "lower": 2125000.0,
    "upper": 2875000.0
  },
  "prediction_timestamp": "2026-01-18T10:30:00"
}
```

### Testing the API

```bash
# Health check
curl http://localhost:8000/health

# Make prediction
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "city": "Rabat",
    "surface_area": 80,
    "nb_baths": 1,
    "total_rooms": 2,
    "equipment_list": ["Parking"]
  }'
```

## 📈 Model Performance

| Metric | Value | Meaning |
|--------|-------|---------|
| **R² Score** | 82.69% | 82.7% of price variation explained |
| **MAE** | 185,807 MAD | Average prediction error |
| **RMSE** | 273,802 MAD | Root mean squared error |
| **MAPE** | 18.13% | Average percentage error |

### Performance by City
- **Best**: Casablanca, Rabat (higher accuracy)
- **Good**: Marrakech, Fès, Tanger
- **Variable**: Smaller cities (limited data)

## 🧪 Testing

### Automated Tests
```bash
# Run all tests
python -m pytest

# Test specific components
python -m pytest tests/test_api.py
python -m pytest tests/test_model.py
```

### Manual Testing
1. **API Tests**: Use the `/health` endpoint
2. **Frontend Tests**: Try different inputs and cities
3. **Model Tests**: Compare predictions with known data

## 🚀 Deployment

### Local Development
```bash
# Start backend only
cd backend && python main.py

# Start frontend only
cd frontend && streamlit run app.py

# Start both (production)
./start.sh  # or start.bat
```

### Production Deployment
```bash
# Using Docker (recommended)
docker build -t real-estate-predictor .
docker run -p 8000:8000 -p 8501:8501 real-estate-predictor

# Using cloud platforms
# - Heroku, Railway, Render for backend
# - Streamlit Cloud for frontend
# - AWS/GCP/Azure for full deployment
```

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes
4. **Test** thoroughly
5. **Commit** (`git commit -m 'Add amazing feature'`)
6. **Push** (`git push origin feature/amazing-feature`)
7. **Open** a Pull Request

### Ways to Contribute
- 🐛 **Bug fixes** - report and fix issues
- ✨ **Features** - add new functionality
- 📚 **Documentation** - improve guides and docs
- 🧪 **Tests** - add test cases
- 🌍 **Localization** - add more languages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the Moroccan real estate market**

⭐ **Star this repo** if you find it useful!
🔗 **Share** with fellow developers and real estate enthusiasts!

*For questions or support, please open an issue on GitHub.*
