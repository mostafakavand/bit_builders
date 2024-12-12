from fastapi import FastAPI, File, UploadFile, Form
import cv2
import numpy as np
import os
import json
from typing import Dict

class FaceFeatureExtractor:
    def __init__(self):
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    
    def extract_features(self, face_image) -> Dict:
        face = cv2.resize(face_image, (200, 200))
        gray = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
        
        # اضافه کردن ویژگی‌های جدید
        features = {
            "histogram": cv2.calcHist([gray], [0], None, [256], [0, 256]).flatten().tolist(),
            "mean_intensity": float(np.mean(gray)),
            "std_intensity": float(np.std(gray)),
            "face_area": int(face.shape[0] * face.shape[1]),
            "edge_density": float(np.mean(cv2.Canny(gray, 100, 200))),
            "symmetry_score": self._calculate_symmetry(gray),
            "local_binary_pattern": self._calculate_lbp(gray).tolist(),
            "gabor_features": self._calculate_gabor(gray).tolist(),
            "facial_landmarks": self._get_facial_landmarks(face),
            "texture_features": self._calculate_texture(gray).tolist()
        }
        return features
    
    def _calculate_symmetry(self, gray_image):
        height, width = gray_image.shape
        left_half = gray_image[:, :width//2]
        right_half = cv2.flip(gray_image[:, width//2:], 1)
        symmetry_score = float(np.mean(np.abs(left_half - right_half)))
        return symmetry_score
    def _calculate_lbp(self, gray_image):
        rows, cols = gray_image.shape
        lbp = np.zeros_like(gray_image)
        
        for i in range(1, rows-1):
            for j in range(1, cols-1):
                center = gray_image[i, j]
                # Get 8 neighbors only
                pixels = [
                    gray_image[i-1, j-1], gray_image[i-1, j], gray_image[i-1, j+1],
                    gray_image[i, j-1],                       gray_image[i, j+1],
                    gray_image[i+1, j-1], gray_image[i+1, j], gray_image[i+1, j+1]
                ]
                binary = np.array(pixels) >= center
                lbp[i, j] = np.sum(binary * 2**np.arange(8))
        
        return np.histogram(lbp, bins=256, range=(0,256))[0]
    def _calculate_gabor(self, gray_image):
        # Simple Gabor filter implementation
        ksize = 33
        sigma = 5.0
        theta = np.pi/4
        lambd = 10.0
        gamma = 0.5
        
        kernel = cv2.getGaborKernel((ksize, ksize), sigma, theta, lambd, gamma)
        filtered = cv2.filter2D(gray_image, cv2.CV_8UC3, kernel)
        return np.mean(filtered, axis=(0,1))
    
    def _get_facial_landmarks(self, face):
        # Simplified facial landmarks
        gray = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
        return np.mean(gray)
    
    def _calculate_texture(self, gray_image):
        # GLCM texture features
        glcm = np.zeros((8,8))
        h, w = gray_image.shape
        for i in range(h-1):
            for j in range(w-1):
                glcm[gray_image[i,j]//32, gray_image[i,j+1]//32] += 1
        return glcm.flatten()

class FaceDatabase:
    def __init__(self, db_path="face_features.json"):
        self.db_path = db_path
        self.features_db = self._load_db()
    
    def _load_db(self):
        if os.path.exists(self.db_path):
            with open(self.db_path, 'r') as f:
                return json.load(f)
        return {}
    
    def save_features(self, name: str, features: Dict):
        self.features_db[name] = features
        with open(self.db_path, 'w') as f:
            json.dump(self.features_db, f)
    
    def compare_features(self, new_features: Dict) -> tuple[bool, str]:
        similarity_threshold = 0.40
        max_similarity = 0
        matched_name = ""
        
        for name, stored_features in self.features_db.items():
            similarity_score = self._calculate_similarity(new_features, stored_features)
            if similarity_score > max_similarity:
                max_similarity = similarity_score
                matched_name = name
        
        if max_similarity > similarity_threshold:
            return True, matched_name
        return False, ""
    
    def _calculate_similarity(self, features1: Dict, features2: Dict) -> float:
        weights = {
            "histogram": 0.15,
            "mean_intensity": 0.05,
            "std_intensity": 0.05,
            "face_area": 0.05,
            "edge_density": 0.1,
            "symmetry_score": 0.1,
            "local_binary_pattern": 0.2,
            "gabor_features": 0.15,
            "facial_landmarks": 0.1,
            "texture_features": 0.05
        }
        
        total_similarity = 0
        
        # Handle histogram comparison separately
        hist_correlation = np.corrcoef(features1["histogram"], features2["histogram"])[0,1]
        total_similarity += weights["histogram"] * max(0, hist_correlation)
        
        # Compare other features with zero-division protection
        for feature in ["mean_intensity", "std_intensity", "face_area", "edge_density", "symmetry_score"]:
            val1 = features1[feature]
            val2 = features2[feature]
            if val1 == 0 and val2 == 0:
                similarity = 1.0  # If both values are zero, they are identical
            elif val1 == 0 or val2 == 0:
                similarity = 0.0  # If only one value is zero, they are completely different
            else:
                max_val = max(abs(val1), abs(val2))
                similarity = 1 - min(1, abs(val1 - val2) / max_val)
            total_similarity += weights[feature] * similarity
        
        return total_similarity
class FaceDetectionAPI:
    def __init__(self, image_folder="images"):
        self.app = FastAPI()
        self.IMAGE_FOLDER = image_folder
        os.makedirs(self.IMAGE_FOLDER, exist_ok=True)
        self.feature_extractor = FaceFeatureExtractor()
        self.face_db = FaceDatabase()
        self.setup_routes()
    
    def setup_routes(self):
        @self.app.post("/check-face/")
        async def check_face(file: UploadFile = File(...)):
            contents = await file.read()
            nparr = np.frombuffer(contents, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            face = self.extract_face(image)
            if face is None:
                return {
                    "status": "error",
                    "message": "No face detected in image"
                }
                
            features = self.feature_extractor.extract_features(face)
            face_exists, existing_name = self.face_db.compare_features(features)
            
            if face_exists:
                return {
                    "status": "duplicate",
                    "message": f"Face already exists as {existing_name}",
                    "existing_name": existing_name
                }
            
            return {
                "status": "unique",
                "message": "Face is new, please provide a name",
                "require_name": True
            }

        @self.app.post("/save-face/")
        async def save_face(file: UploadFile = File(...), name: str = Form(...)):
            contents = await file.read()
            nparr = np.frombuffer(contents, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            face = self.extract_face(image)
            if face is not None:
                features = self.feature_extractor.extract_features(face)
                image_path = os.path.join(self.IMAGE_FOLDER, f"{name}.jpg")
                cv2.imwrite(image_path, face)
                self.face_db.save_features(name, features)
                
                return {
                    "status": "success",
                    "message": f"New face saved as {name}",
                    "features": features
                }

    def extract_face(self, image):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = self.feature_extractor.face_cascade.detectMultiScale(gray, 1.1, 4)
        if len(faces) > 0:
            (x, y, w, h) = faces[0]
            return image[y:y+h, x:x+w]
        return None

api = FaceDetectionAPI()
app = api.app

