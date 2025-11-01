class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.arogyaraksha.com/v1';
  static const String digiLockerBaseUrl = 'https://api.digitallocker.gov.in';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String signup = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String refreshToken = '$baseUrl/auth/refresh-token';

  // User Endpoints
  static const String getUserProfile = '$baseUrl/users/profile';
  static const String updateUserProfile = '$baseUrl/users/profile';
  static const String uploadProfileImage = '$baseUrl/users/profile/image';
  static const String deleteAccount = '$baseUrl/users/delete';

  // Emergency Endpoints
  static const String triggerEmergency = '$baseUrl/emergency/trigger';
  static const String cancelEmergency = '$baseUrl/emergency/cancel';
  static const String getEmergencyStatus = '$baseUrl/emergency/status';
  static const String getEmergencyHistory = '$baseUrl/emergency/history';
  static const String updateEmergencyLocation = '$baseUrl/emergency/location';

  // Ambulance Endpoints
  static const String getNearestAmbulance = '$baseUrl/ambulance/nearest';
  static const String getAmbulanceStatus = '$baseUrl/ambulance/status';
  static const String trackAmbulance = '$baseUrl/ambulance/track';
  static const String rateAmbulance = '$baseUrl/ambulance/rate';

  // Hospital Endpoints
  static const String getNearestHospitals = '$baseUrl/hospitals/nearest';
  static const String getHospitalDetails = '$baseUrl/hospitals';
  static const String sendPatientData = '$baseUrl/hospitals/patient-data';
  static const String getHospitalCapacity = '$baseUrl/hospitals/capacity';

  // Insurance Endpoints
  static const String verifyInsurance = '$baseUrl/insurance/verify';
  static const String getInsuranceDetails = '$baseUrl/insurance/details';
  static const String updateInsurance = '$baseUrl/insurance/update';
  static const String getClaimsHistory = '$baseUrl/insurance/claims';
  static const String submitClaim = '$baseUrl/insurance/claims/submit';

  // Blood Bank Endpoints
  static const String requestBlood = '$baseUrl/blood/request';
  static const String getNearbyDonors = '$baseUrl/blood/donors/nearby';
  static const String registerDonor = '$baseUrl/blood/donors/register';
  static const String getBloodInventory = '$baseUrl/blood/inventory';
  static const String donateBlood = '$baseUrl/blood/donate';

  // Vitals Endpoints
  static const String addVitals = '$baseUrl/vitals/add';
  static const String getVitals = '$baseUrl/vitals';
  static const String getVitalsHistory = '$baseUrl/vitals/history';
  static const String deleteVitals = '$baseUrl/vitals/delete';

  // AI Health Alerts
  static const String getHealthAlerts = '$baseUrl/ai/alerts';
  static const String getPredictions = '$baseUrl/ai/predictions';
  static const String analyzeVitals = '$baseUrl/ai/analyze';
  static const String getRiskScore = '$baseUrl/ai/risk-score';

  // Notifications
  static const String getNotifications = '$baseUrl/notifications';
  static const String markAsRead = '$baseUrl/notifications/read';
  static const String deleteNotification = '$baseUrl/notifications/delete';
  static const String getNotificationSettings = '$baseUrl/notifications/settings';
  static const String updateNotificationSettings = '$baseUrl/notifications/settings';

  // DigiLocker Integration
  static const String digiLockerAuth = '$digiLockerBaseUrl/oauth2/authorize';
  static const String digiLockerToken = '$digiLockerBaseUrl/oauth2/token';
  static const String digiLockerDocuments = '$digiLockerBaseUrl/api/documents';
  static const String digiLockerProfile = '$digiLockerBaseUrl/api/profile';

  // Device Endpoints
  static const String pairDevice = '$baseUrl/devices/pair';
  static const String getDevices = '$baseUrl/devices';
  static const String updateDevice = '$baseUrl/devices/update';
  static const String deleteDevice = '$baseUrl/devices/delete';

  // SMS & Voice
  static const String sendSms = '$baseUrl/sms/send';
  static const String sendVoiceAlert = '$baseUrl/voice/alert';

  // Location & Maps
  static const String geocode = '$baseUrl/location/geocode';
  static const String reverseGeocode = '$baseUrl/location/reverse';
  static const String getRoute = '$baseUrl/location/route';

  // Support
  static const String contactSupport = '$baseUrl/support/contact';
  static const String getFaq = '$baseUrl/support/faq';
  static const String reportIssue = '$baseUrl/support/report';
}