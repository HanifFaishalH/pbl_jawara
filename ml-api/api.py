from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
import numpy as np
import tensorflow as tf
import joblib 
import cv2
from skimage.feature import graycomatrix, graycoprops, local_binary_pattern

app = FastAPI(title="DNN Batik Classifier API", version="1.0")

# 1. === Load model dan scaler ===
model = tf.keras.models.load_model("dnn_model_GLCM + LBP.h5")
scaler = joblib.load("dnn_scalerr_GLCM+LBP.pkl")

# === Kelas sesuai training ===
classes = ["Batik Cap", "Batik Tulis"]

# === 2. Fungsi ekstraksi fitur ===
def extract_features(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    glcm = graycomatrix(
        gray,
        distances=[1, 2, 3],
        angles=[0, np.pi/4, np.pi/2, 3*np.pi/4],
        levels=256,
        symmetric=True,
        normed=True
    )

    glcm_feats = np.hstack([
        graycoprops(glcm, prop).flatten()
        for prop in ['contrast', 'dissimilarity', 'homogeneity', 'energy', 'correlation']
    ])

    lbp = local_binary_pattern(gray, 8, 1, method='uniform')
    hist, _ = np.histogram(lbp.ravel(), bins=10, range=(0, 10))
    hist = hist / (hist.sum() + 1e-7)

    return np.hstack((glcm_feats, hist))


# === 3. Endpoint utama ===
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)

        # Ekstraksi fitur
        feats = extract_features(image)
        scaled = scaler.transform([feats])

        # Prediksi
        probs = model.predict(scaled)
        probs = np.array(probs).flatten()  # pastikan array 1D

        if probs.shape[0] == 1:
            # Binary classifier (sigmoid)
            score = probs[0]
            label = "Batik Tulis" if score > 0.5 else "Batik Cap"
            confidence = round(float(score * 100 if score > 0.5 else (1 - score) * 100), 2)
            probabilities = {"Batik Cap": round(float(1 - score), 4),
                             "Batik Tulis": round(float(score), 4)}
        else:
            # Multiclass (softmax)
            idx = np.argmax(probs)
            label = classes[idx]
            confidence = round(float(np.max(probs) * 100), 2)
            probabilities = {classes[i]: round(float(probs[i]), 4) for i in range(len(classes))}

        return JSONResponse({
            "kategori_prediksi": label,
            "confidence": confidence,
            "probabilities": probabilities
        })

    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return JSONResponse({"error": str(e)}, status_code=500)
