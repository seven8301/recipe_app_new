# 🍳 recipe_app — AI-Powered Recipe Recommendation App

**recipe_app** is a cross-platform Flutter mobile application that helps users identify fridge ingredients and receive personalized recipe recommendations powered by **AI, YOLOv10**, and **CBF (Content-Based Filtering)**.

---

## 🚀 Features

- 📸 **Ingredient Recognition**  
  Upload or capture fridge photos to detect ingredients using **YOLOv10-Nano**
- 🧠 **Personalized Recipe Recommendation**  
  Content-Based Filtering (CBF) recommendations aligned with dietary preferences
- 🍽️ **Dietary Preference Filters**  
  Gluten-free, dairy-free, vegan, halal, etc.
- 👤 **User Authentication**  
  Sign up / Login with token-based authentication (FastAPI + JWT)
- 🧾 **Recipe Management**  
  Browse, save, and manage recommended recipes

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| Frontend | Flutter (Dart) |
| Backend | FastAPI (Python) |
| Database | MySQL |
| AI Model | YOLOv10 + CBF |
| Authentication | JWT |
| Dataset | Custom ingredient dataset (beef, potato, fridge scenes) |

---

## 🧠 System Architecture

Flutter App → FastAPI (REST API) → MySQL Database
↓
YOLOv10 + CBF Model

---

## ⚙️ Setup Guide

### 🔹 1. Backend (FastAPI)
```bash
cd server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 7777

🔹 2. Database Setup
CREATE DATABASE rec_app;
USE rec_app;
SOURCE rec-app.sql;
Then edit your MySQL connection in:
server/core/mysql.py
Find this line:
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:@localhost:3306/rec_app"
Replace it with your own password, for example:
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:1234@localhost:3306/rec_app"

🔹 3. Frontend Setup
cd recipe_app
flutter pub get
flutter run
If you are using Android Emulator, modify your API base URL in
lib/common/values/server.dart:
const SERVER_API_URL = "http://10.0.2.2:7777";
For iOS Simulator:
const SERVER_API_URL = "http://127.0.0.1:7777";
For Real Device (same Wi-Fi):
const SERVER_API_URL = "http://<your-computer-IP>:7777";


👥 Team
Seven Yue, Cheng Fei, Jing Cong, Michael Le, Raj Xavier Rozario, Xiaowen Wu
Future Interns Team (UOW Capstone Project)
Supervisor: Dr. Hui Luo

🏗️ Future Work
Combine CBF with Collaborative Filtering
Cloud deployment (AWS / Render / Railway)
Nutrition-based recommendation
Multi-language UI support

📜 License
MIT License © 2025 Future Interns Team
