"""
🏠 SalesHouses - FastAPI Backend
API for Moroccan Real Estate Price Prediction

Similar to CarPriceML API structure
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import subprocess
from pydantic import BaseModel, Field
from pathlib import Path
import joblib
import pandas as pd
import json
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ========== CONFIGURATION ==========
MODEL_DIR = Path(__file__).parent / "models"
if not MODEL_DIR.exists():
    MODEL_DIR = Path(__file__).parent.parent / "models"

ml_model = None
scaler = None
metadata = None
numeric_features = None

# ========== SCHÉMAS ==========
class ApartmentRequest(BaseModel):
    """Caractéristiques de l'appartement"""
    city: str = Field(..., description="Ville (ex: 'Casablanca', 'Rabat', 'Marrakech')")
    surface_area: float = Field(..., gt=0, le=500, description="Surface en m²")
    nb_baths: int = Field(..., ge=0, le=10, description="Nombre de salles de bain")
    total_rooms: int = Field(..., ge=1, le=15, description="Nombre total de pièces")
    equipment_list: list = Field(default=[], description="Liste des équipements")

    class Config:
        json_schema_extra = {
            "example": {
                "city": "Casablanca",
                "surface_area": 100.0,
                "nb_baths": 2,
                "total_rooms": 3,
                "equipment_list": ["Ascenseur", "Balcon", "Parking"]
            }
        }

class PredictionResponse(BaseModel):
    """Réponse de prédiction"""
    predicted_price: float
    price_per_m2: float
    confidence_interval: dict
    prediction_timestamp: str

# ========== CYCLE DE VIE ==========
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Charger le modèle au démarrage"""
    global ml_model, scaler, metadata, numeric_features

    try:
        # Charger le modèle
        ml_model = joblib.load(MODEL_DIR / "best_model.pkl")
        logger.info("✅ Modèle chargé")

        # Charger le scaler
        scaler = joblib.load(MODEL_DIR / "scaler.pkl")
        logger.info("✅ Scaler chargé")

        # Charger les métadonnées
        metadata_path = MODEL_DIR / "metadata.json"
        if metadata_path.exists():
            with open(metadata_path, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            logger.info("✅ Métadonnées chargées")

            # Extraire les features numériques
            numeric_features = metadata.get('numeric_features', [])

    except Exception as e:
        logger.error(f"❌ Erreur de chargement: {e}")
        ml_model = None
        scaler = None
        metadata = None

    yield

    # Nettoyage
    ml_model = None
    scaler = None
    metadata = None

# ========== FONCTION PREDICT ==========
def predict(city: str, surface_area: float, nb_baths: int, total_rooms: int, equipment_list: list = None) -> dict:
    """
    Prédit le prix d'un appartement

    Args:
        city: Nom de la ville
        surface_area: Surface en m²
        nb_baths: Nombre de salles de bain
        total_rooms: Nombre total de pièces
        equipment_list: Liste des équipements

    Returns:
        dict: Résultats de la prédiction
    """
    if ml_model is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")

    if equipment_list is None:
        equipment_list = []

    # Créer le vecteur de features
    features = {}

    # Features de base
    features['surface_area'] = surface_area
    features['nb_baths'] = nb_baths
    features['total_rooms'] = total_rooms

    # Features engineered
    features['bath_room_ratio'] = nb_baths / (total_rooms + 1)
    features['surface_per_room'] = surface_area / (total_rooms + 1)
    features['equipment_score'] = len(equipment_list)

    # One-hot encoding ville
    city_col = f'city_{city}'
    for city_feature in metadata['city_features']:
        features[city_feature] = 1 if city_feature == city_col else 0

    # One-hot encoding équipements
    for equip_feature in metadata['equipment_features']:
        features[equip_feature] = 1 if equip_feature in equipment_list else 0

    # Convertir en DataFrame
    df = pd.DataFrame([features])

    # Assurer que toutes les features sont présentes
    for feature in metadata['feature_names']:
        if feature not in df.columns:
            df[feature] = 0

    # Réorganiser les colonnes
    df = df[metadata['feature_names']]

    # Normaliser les features numériques
    if numeric_features:
        df[numeric_features] = scaler.transform(df[numeric_features])

    # Prédiction
    predicted_price = float(ml_model.predict(df)[0])
    price_per_m2 = predicted_price / surface_area

    # Intervalle de confiance
    confidence_interval = {
        'lower': round(predicted_price * 0.85, 2),
        'upper': round(predicted_price * 1.15, 2)
    }

    return {
        'predicted_price': round(predicted_price, 2),
        'price_per_m2': round(price_per_m2, 2),
        'confidence_interval': confidence_interval,
        'prediction_timestamp': datetime.now().isoformat()
    }

# ========== TRAIN ENDPOINT ==========
@app.post("/train")
def train_model():
    """Lance l'entraînement du modèle"""
    try:
        # Run the training script from the project root
        result = subprocess.run(
            ["python", "notebooks/script.py"], 
            cwd=Path(__file__).parent.parent,  # Set cwd to project root
            capture_output=True, 
            text=True
        )
        if result.returncode == 0:
            return {"status": "success", "message": "Training completed successfully"}
        else:
            return {"status": "error", "message": result.stderr}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.post("/reload")
def reload_model():
    """Recharge le modèle depuis les fichiers"""
    global ml_model, scaler, metadata, numeric_features
    try:
        # Recharger le modèle
        ml_model = joblib.load(MODEL_DIR / "best_model.pkl")
        logger.info("✅ Modèle rechargé")

        # Recharger le scaler
        scaler = joblib.load(MODEL_DIR / "scaler.pkl")
        logger.info("✅ Scaler rechargé")

        # Recharger les métadonnées
        metadata_path = MODEL_DIR / "metadata.json"
        if metadata_path.exists():
            with open(metadata_path, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            logger.info("✅ Métadonnées rechargées")

            # Extraire les features numériques
            numeric_features = metadata.get('numeric_features', [])

        return {"status": "success", "message": "Model reloaded successfully"}
    except Exception as e:
        logger.error(f"❌ Erreur de rechargement: {e}")
        return {"status": "error", "message": str(e)}

# ========== APP ==========
app = FastAPI(title="SalesHouses API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========== ENDPOINTS ==========
@app.get("/")
def root():
    return {"message": "SalesHouses API", "endpoint": "/predict"}

@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_loaded": ml_model is not None,
        "scaler_loaded": scaler is not None,
        "metadata_loaded": metadata is not None
    }

@app.post("/predict", response_model=PredictionResponse)
def predict_apartment_price(data: ApartmentRequest):
    """Prédit le prix d'un appartement"""
    result = predict(
        city=data.city,
        surface_area=data.surface_area,
        nb_baths=data.nb_baths,
        total_rooms=data.total_rooms,
        equipment_list=data.equipment_list
    )

    return PredictionResponse(**result)

# ========== DÉMARRAGE LOCAL ==========
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)