from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
import numpy as np
import tensorflow as tf
import joblib 
import cv2
from skimage.feature import graycomatrix, graycoprops, local_binary_pattern

app = FastAPI(title="DNN Batik Classifier API", version="1.1")

# =================================================================================
# 1. Load model & scaler
# =================================================================================
MODEL_PATH = "dnn_model_GLCM+LBP.h5"
SCALER_PATH = "dnn_scaler_GLCM+LBP.pkl"
THRESHOLD_TULIS = 0.50  # ambil dari konfigurasi Flask

classes = ["Batik Cap", "Batik Tulis"]

model = tf.keras.models.load_model(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

print("✅ Model dan Scaler berhasil dimuat.")

# =================================================================================
# 2. Fungsi PREPROCESSING (sama persis dengan versi Flask)
# =================================================================================
def preprocess_image(img_bgr):
    """Langkah preprocessing: resize, brightness/contrast, CLAHE, bilateral, grayscale"""
    target_size = (224, 224)
    img_resized = cv2.resize(img_bgr, target_size)

    # 2. Brightness & Contrast
    alpha = 1.2
    beta = 10
    bright_contrast = cv2.convertScaleAbs(img_resized, alpha=alpha, beta=beta)

    # 3. CLAHE (pada channel L)
    lab = cv2.cvtColor(bright_contrast, cv2.COLOR_BGR2LAB)
    L, A, B = cv2.split(lab)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    cl = clahe.apply(L)
    lab_clahe = cv2.merge((cl, A, B))
    clahe_img = cv2.cvtColor(lab_clahe, cv2.COLOR_LAB2BGR)

    # 4. Bilateral Filter
    bilateral = cv2.bilateralFilter(clahe_img, d=7, sigmaColor=50, sigmaSpace=50)

    # 5. Grayscale
    gray_final = cv2.cvtColor(bilateral, cv2.COLOR_BGR2GRAY)
    return gray_final

# =================================================================================
# 3. FUNGSI EKSTRAKSI FITUR (GLCM + LBP)
# =================================================================================
def extract_features(image):
    """Ekstraksi fitur GLCM + LBP setelah preprocessing"""
    gray = preprocess_image(image)

    # --- A. GLCM ---
    distances = [1, 2, 3]
    angles = [0, np.pi/4, np.pi/2, 3*np.pi/4]
    glcm = graycomatrix(
        gray,
        distances=distances,
        angles=angles,
        levels=256,
        symmetric=True,
        normed=True
    )

    props = ['contrast', 'dissimilarity', 'homogeneity', 'energy', 'correlation']
    glcm_feats = np.hstack([
        graycoprops(glcm, prop).flatten()
        for prop in props
    ])

    # --- B. LBP ---
    radius = 1
    n_points = 8 * radius
    lbp = local_binary_pattern(gray, n_points, radius, method='uniform')
    n_bins = n_points + 2
    hist, _ = np.histogram(lbp.ravel(), bins=n_bins, range=(0, n_bins))
    hist = hist.astype("float")
    hist /= (hist.sum() + 1e-7)

    # --- C. Gabungkan dan scale ---
    combined = np.hstack((glcm_feats, hist)).reshape(1, -1)
    scaled = scaler.transform(combined)
    return scaled

# =================================================================================
# 4. Endpoint Prediksi
# =================================================================================
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)

        feats_scaled = extract_features(image)
        probs = model.predict(feats_scaled)
        probs = np.array(probs).flatten()

        # === Model output sigmoid (1 neuron)
        if probs.shape[0] == 1:
            score = probs[0]
            label = classes[1] if score > THRESHOLD_TULIS else classes[0]
            confidence = round(float(score * 100 if score > THRESHOLD_TULIS else (1 - score) * 100), 2)
            probabilities = {
                "Batik Cap": round(float(1 - score), 4),
                "Batik Tulis": round(float(score), 4)
            }
        else:
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
