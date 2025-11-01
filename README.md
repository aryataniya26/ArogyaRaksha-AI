# 🏥 ArogyaRaksha AI - Backend API

**Smart Health Emergency Response System** - Node.js Backend with Firebase Integration

[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org/)
[![Firebase](https://img.shields.io/badge/Firebase-Admin-orange.svg)](https://firebase.google.com/)
[![Express](https://img.shields.io/badge/Express-4.x-blue.svg)](https://expressjs.com/)

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Server](#running-the-server)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Deployment](#deployment)

---

## ✨ Features

### 🚨 Emergency Management
- One-click emergency trigger
- Auto-assign nearest ambulance
- Real-time ambulance tracking (WebSocket)
- SMS & push notifications
- Offline mode support

### 🚑 Ambulance System
- Nearest ambulance finder (15km radius)
- Real-time location updates
- Driver status management
- Auto-assignment algorithm

### 🏥 Hospital Integration
- Find nearest hospitals (20km radius)
- Pre-arrival patient data notification
- Bed availability management
- Insurance verification

### 💳 Insurance Support
- Ayushman Bharat integration
- Aarogyasri support
- Private insurance verification
- DigiLocker document fetch
- Pre-approval to hospitals

### ❤️ Health Monitoring
- Vitals recording (BP, Sugar, HR, SpO2)
- AI-powered health predictions
- Abnormal vitals alerts
- Emergency risk prediction

### 🩸 Blood Bank System
- Blood request creation
- Nearest blood bank finder
- Auto-notify matching blood banks
- Real-time availability tracking

---

## 🛠️ Tech Stack

- **Runtime:** Node.js 16+
- **Framework:** Express.js
- **Database:** Firebase Firestore
- **Authentication:** Firebase Auth
- **Real-time:** Socket.io
- **SMS:** Twilio + Fast2SMS
- **Maps:** Google Maps API
- **Push Notifications:** Firebase Cloud Messaging
- **AI:** Python Flask (optional)

---

## 📦 Prerequisites

Before you begin, ensure you have:

- **Node.js** (v16 or higher)
- **npm** or **yarn**
- **Firebase Project** with Admin SDK credentials
- **Twilio Account** (for SMS) or **Fast2SMS API Key**
- **Google Maps API Key**
- **Firebase Cloud Messaging** server key

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd arogyaraksha-backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials (see [Configuration](#configuration))

### 4. Seed Sample Data (Optional)

```bash
# Seed hospitals
npm run seed:hospitals

# Seed ambulances
npm run seed:ambulances

# Seed blood banks
npm run seed:blood

# Seed all at once
npm run seed:all
```

---

## ⚙️ Configuration

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Download the JSON file
6. Extract these values to your `.env`:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@....iam.gserviceaccount.com
```

### SMS Configuration

**Option 1: Twilio (International)**
```env
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890
```

**Option 2: Fast2SMS (Indian Numbers)**
```env
FAST2SMS_API_KEY=your-fast2sms-api-key
```

### Google Maps API

```env
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

Enable these APIs:
- Geocoding API
- Directions API
- Places API

### Other Services

```env
# DigiLocker (Optional)
DIGILOCKER_CLIENT_ID=your-client-id
DIGILOCKER_CLIENT_SECRET=your-client-secret

# Firebase Cloud Messaging
FCM_SERVER_KEY=your-fcm-server-key
```

---

## 🏃 Running the Server

### Development Mode

```bash
npm run dev
```

Server will start at: `http://localhost:5000`

### Production Mode

```bash
npm start
```

---

## 📡 API Documentation

### Base URL
```
http://localhost:5000/api/v1
```

### Authentication

All protected routes require Firebase ID token in header:

```http
Authorization: Bearer <firebase_id_token>
```

### API Endpoints

#### 🚨 Emergency APIs

```http
POST   /emergency/trigger           # Trigger emergency
GET    /emergency/:emergencyId      # Get status
PUT    /emergency/:emergencyId/status  # Update status
POST   /emergency/:emergencyId/cancel  # Cancel emergency
GET    /emergency/history/user      # Get user history
```

#### 👤 User APIs

```http
GET    /user/profile                # Get profile
PUT    /user/profile                # Update profile
POST   /user/emergency-contact      # Add emergency contact
PUT    /user/device-token           # Update FCM token
PUT    /user/location               # Update location
```

#### 🚑 Ambulance APIs

```http
GET    /ambulance/nearest           # Find nearest
GET    /ambulance/:ambulanceId      # Get details
PUT    /ambulance/:id/location      # Update location
POST   /ambulance/:id/arrived       # Mark arrived
POST   /ambulance/:id/picked        # Mark patient picked
POST   /ambulance/:id/reached-hospital  # Mark reached
POST   /ambulance/:id/complete      # Complete ride
```

#### 🏥 Hospital APIs

```http
GET    /hospital/nearest            # Find nearest
GET    /hospital/:hospitalId        # Get details
GET    /hospital/beds/available     # Hospitals with beds
GET    /hospital/search/query       # Search hospitals
PUT    /hospital/:id/beds           # Update bed availability
```

#### 💳 Insurance APIs

```http
POST   /insurance/verify            # Verify insurance
GET    /insurance/status            # Get status
GET    /insurance/details           # Get details
POST   /insurance/add               # Add insurance
POST   /insurance/digilocker        # Fetch from DigiLocker
GET    /insurance/coverage          # Get coverage
```

#### ❤️ Vitals APIs

```http
POST   /vitals/record               # Record vitals
GET    /vitals/history              # Get history
GET    /vitals/latest               # Get latest
GET    /vitals/alerts               # Get alerts
POST   /vitals/analyze              # AI analysis
GET    /vitals/predict-risk         # Predict emergency risk
```

#### 🩸 Blood APIs

```http
POST   /blood/request               # Create request
GET    /blood/request/:requestId    # Get status
GET    /blood/banks/nearest         # Find nearest banks
GET    /blood/bank/:id/availability # Check availability
```

#### 🔔 Notification APIs

```http
GET    /notification/all            # Get all
PUT    /notification/:id/read       # Mark as read
PUT    /notification/read-all       # Mark all as read
GET    /notification/unread-count   # Get unread count
```

---

## 🧪 Testing

### Manual Testing with Postman

1. Import the Postman collection (if available)
2. Set environment variables
3. Get Firebase token from your Flutter app
4. Add token to Authorization header
5. Test APIs

### Example Emergency Trigger Request

```json
POST /api/v1/emergency/trigger
Headers: {
  "Authorization": "Bearer <firebase_token>",
  "Content-Type": "application/json"
}
Body: {
  "location": {
    "latitude": 17.4065,
    "longitude": 78.4772
  },
  "emergencyType": "cardiac",
  "symptoms": ["chest pain", "shortness of breath"],
  "vitals": {
    "heartRate": 120,
    "bloodPressure": {
      "systolic": 160,
      "diastolic": 100
    }
  }
}
```

---

## 🚀 Deployment

### Option 1: Render.com

1. Create account on [Render](https://render.com/)
2. Click **New** → **Web Service**
3. Connect your Git repository
4. Set build command: `npm install`
5. Set start command: `npm start`
6. Add environment variables
7. Deploy!

### Option 2: Railway.app

1. Go to [Railway](https://railway.app/)
2. Click **New Project** → **Deploy from GitHub**
3. Select repository
4. Add environment variables
5. Deploy automatically

### Option 3: AWS/DigitalOcean

```bash
# Install PM2
npm install -g pm2

# Start with PM2
pm2 start server.js --name arogyaraksha-api

# Setup auto-restart
pm2 startup
pm2 save
```

---

## 📂 Project Structure

```
arogyaraksha-backend/
├── src/
│   ├── config/          # Configuration files
│   ├── models/          # Data models (8)
│   ├── services/        # Business logic (8)
│   ├── controllers/     # Request handlers (8)
│   ├── routes/          # API routes (8)
│   ├── middlewares/     # Auth, error handling
│   ├── utils/           # Helper functions
│   └── websocket/       # Real-time communication
├── scripts/             # Seed scripts
├── server.js            # Entry point
├── package.json
└── .env
```

---

## 🔒 Security Notes

- Never commit `.env` file
- Keep Firebase credentials secure
- Use HTTPS in production
- Enable CORS only for trusted origins
- Implement rate limiting (already done)
- Regular security updates

---

## 🐛 Troubleshooting

### Firebase Connection Error
- Check Firebase credentials in `.env`
- Ensure private key is properly formatted
- Verify Firestore is enabled in Firebase Console

### SMS Not Sending
- Check Twilio/Fast2SMS credentials
- Verify phone numbers format (+91...)
- Check account balance

### Location Services Not Working
- Verify Google Maps API key
- Enable required APIs in Google Cloud Console
- Check API quota limits

---

## 📞 Support

For issues or questions:
- Create an issue on GitHub
- Email: support@particle14.com
- Phone: +91-XXXXXXXXXX

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👨‍💻 Author

**Neeraj Kumar**  
CEO - Particle14 Infotech Pvt. Ltd.

---

## 🙏 Acknowledgments

- Firebase Team
- Node.js Community
- Open Source Contributors

---

**Made with ❤️ for saving lives** 🏥🚑


[//]: # (# .env File)

[//]: # (API_BASE_URL=https://api.arogyaraksha.com/v1)

[//]: # (DIGILOCKER_CLIENT_ID=your_digilocker_client_id)

[//]: # (DIGILOCKER_CLIENT_SECRET=your_digilocker_secret)

[//]: # (GOOGLE_MAPS_API_KEY=your_google_maps_key)

[//]: # (FCM_SERVER_KEY=your_fcm_server_key)

[//]: # ()
[//]: # (# README.md)

[//]: # (# ArogyaRaksha AI - Smart Health Emergency Response System)

[//]: # ()
[//]: # (## 🚀 Features)

[//]: # (- One-click emergency alert system)

[//]: # (- AI-powered health predictions)

[//]: # (- Real-time ambulance tracking)

[//]: # (- Insurance validation &#40;DigiLocker integration&#41;)

[//]: # (- Multi-language support &#40;Telugu, Hindi, English&#41;)

[//]: # (- Offline SMS backup for low-network areas)

[//]: # (- Blood donation request system)

[//]: # (- Health vitals monitoring)

[//]: # ()
[//]: # (## 📱 Tech Stack)

[//]: # (- **Frontend**: Flutter &#40;Dart&#41;)

[//]: # (- **Backend**: Firebase + Node.js)

[//]: # (- **Database**: Cloud Firestore)

[//]: # (- **Authentication**: Firebase Auth)

[//]: # (- **Maps**: Google Maps)

[//]: # (- **Notifications**: Firebase Cloud Messaging)

[//]: # (- **State Management**: Provider)

[//]: # (- **Architecture**: MVVM &#40;Clean Architecture&#41;)

[//]: # ()
[//]: # (## 🛠️ Setup Instructions)

[//]: # ()
[//]: # (### Prerequisites)

[//]: # (- Flutter SDK &#40;3.0+&#41;)

[//]: # (- Firebase Project)

[//]: # (- Android Studio / VS Code)

[//]: # (- Node.js &#40;for backend&#41;)

[//]: # ()
[//]: # (### Installation Steps)

[//]: # ()
[//]: # (1. **Clone Repository**)

[//]: # (```bash)

[//]: # (git clone https://github.com/yourusername/arogyaraksha_ai.git)

[//]: # (cd arogyaraksha_ai)

[//]: # (```)

[//]: # ()
[//]: # (2. **Install Dependencies**)

[//]: # (```bash)

[//]: # (flutter pub get)

[//]: # (```)

[//]: # ()
[//]: # (3. **Firebase Setup**)

[//]: # (```bash)

[//]: # (# Install FlutterFire CLI)

[//]: # (dart pub global activate flutterfire_cli)

[//]: # ()
[//]: # (# Configure Firebase)

[//]: # (flutterfire configure)

[//]: # (```)

[//]: # ()
[//]: # (4. **Environment Variables**)

[//]: # (   Create `.env` file in root and add your API keys)

[//]: # ()
[//]: # (5. **Run the App**)

[//]: # (```bash)

[//]: # (flutter run)

[//]: # (```)

[//]: # ()
[//]: # (## 📁 Project Structure)

[//]: # (```)

[//]: # (lib/)

[//]: # (├── core/              # Constants, theme, utils, routes)

[//]: # (├── data/              # Models, repositories, services)

[//]: # (├── domain/            # Use cases &#40;business logic&#41;)

[//]: # (├── presentation/      # UI screens, widgets, viewmodels)

[//]: # (└── providers/         # State management providers)

[//]: # (```)

[//]: # ()
[//]: # (## 🔑 Key Integrations)

[//]: # (- **DigiLocker API**: Insurance document verification)

[//]: # (- **Google Maps**: Location tracking & routing)

[//]: # (- **Firebase**: Authentication, database, storage)

[//]: # (- **FCM**: Push notifications)

[//]: # (- **SMS Gateway**: Offline emergency alerts)

[//]: # ()
[//]: # (## 🎨 Design System)

[//]: # (- **Primary Color**: Teal &#40;#00BFA5&#41;)

[//]: # (- **Secondary Color**: Dark Blue &#40;#0D47A1&#41;)

[//]: # (- **Accent Color**: Light Blue &#40;#4FC3F7&#41;)

[//]: # (- **Alert Color**: Red &#40;#F44336&#41;)

[//]: # ()
[//]: # (## 📄 License)

[//]: # (Copyright © 2025 Particle14 Infotech Pvt. Ltd.)

[//]: # ()
[//]: # (## 👨‍💻 Author)

[//]: # (**Neeraj Kumar**  )

[//]: # (CEO, Particle14 Infotech Pvt. Ltd.)

[//]: # ()
[//]: # (## 📞 Contact)

[//]: # (- Email: support@arogyaraksha.com)

[//]: # (- Website: www.arogyaraksha.com)

[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ()
[//]: # ([//]: # &#40;# arogyaraksha_ai&#41;)
[//]: # ()
[//]: # ([//]: # &#40;&#41;)
[//]: # ([//]: # &#40;A new Flutter project.&#41;)
[//]: # ()
[//]: # ([//]: # &#40;&#41;)
[//]: # ([//]: # &#40;## Getting Started&#41;)
[//]: # ()
[//]: # ([//]: # &#40;&#41;)
[//]: # ([//]: # &#40;This project is a starting point for a Flutter application.&#41;)
[//]: # ()
[//]: # ([//]: # &#40;&#41;)
[//]: # ([//]: # &#40;A few resources to get you started if this is your first Flutter project:&#41;)
[//]: # ()
[//]: # ([//]: # &#40;&#41;)
[//]: # ([//]: # &#40;- [Lab: Write your first Flutter app]&#40;https://docs.flutter.dev/get-started/codelab&#41;&#41;)
[//]: # ()
[//]: # ([//]: # &#40;- [Cookbook: Useful Flutter samples]&#40;https://docs.flutter.dev/cookbook&#41;&#41;)
[//]: # ()
[//]: # ([//]: # &#40;&#41;)
[//]: # ([//]: # &#40;For help getting started with Flutter development, view the&#41;)
[//]: # ()
[//]: # ([//]: # &#40;[online documentation]&#40;https://docs.flutter.dev/&#41;, which offers tutorials,&#41;)
[//]: # ()
[//]: # ([//]: # &#40;samples, guidance on mobile development, and a full API reference.&#41;)
