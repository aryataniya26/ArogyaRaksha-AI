/**
 * Emergency Status
 */
const EmergencyStatus = {
  TRIGGERED: 'triggered',
  AMBULANCE_ASSIGNED: 'ambulance_assigned',
  AMBULANCE_EN_ROUTE: 'ambulance_en_route',
  AMBULANCE_ARRIVED: 'ambulance_arrived',
  PATIENT_PICKED: 'patient_picked',
  EN_ROUTE_HOSPITAL: 'en_route_hospital',
  REACHED_HOSPITAL: 'reached_hospital',
  ADMITTED: 'admitted',
  CANCELLED: 'cancelled',
  COMPLETED: 'completed',
};

/**
 * Emergency Types
 */
const EmergencyType = {
  CARDIAC: 'cardiac',
  STROKE: 'stroke',
  ACCIDENT: 'accident',
  PREGNANCY: 'pregnancy',
  BREATHING: 'breathing',
  TRAUMA: 'trauma',
  POISONING: 'poisoning',
  BURN: 'burn',
  SEIZURE: 'seizure',
  OTHER: 'other',
};

/**
 * Ambulance Status
 */
const AmbulanceStatus = {
  AVAILABLE: 'available',
  ASSIGNED: 'assigned',
  EN_ROUTE: 'en_route',
  ARRIVED: 'arrived',
  TRANSPORTING: 'transporting',
  OFFLINE: 'offline',
  MAINTENANCE: 'maintenance',
};

/**
 * Blood Groups
 */
const BloodGroup = {
  A_POSITIVE: 'A+',
  A_NEGATIVE: 'A-',
  B_POSITIVE: 'B+',
  B_NEGATIVE: 'B-',
  O_POSITIVE: 'O+',
  O_NEGATIVE: 'O-',
  AB_POSITIVE: 'AB+',
  AB_NEGATIVE: 'AB-',
};

/**
 * Insurance Status
 */
const InsuranceStatus = {
  ACTIVE: 'active',
  EXPIRED: 'expired',
  PENDING: 'pending',
  REJECTED: 'rejected',
  VERIFIED: 'verified',
};

/**
 * Insurance Providers
 */
const InsuranceProvider = {
  AYUSHMAN_BHARAT: 'ayushman_bharat',
  AAROGYASRI: 'aarogyasri',
  PRIVATE: 'private',
  NONE: 'none',
};

/**
 * Notification Types
 */
const NotificationType = {
  EMERGENCY_TRIGGERED: 'emergency_triggered',
  AMBULANCE_ASSIGNED: 'ambulance_assigned',
  AMBULANCE_ARRIVED: 'ambulance_arrived',
  HOSPITAL_REACHED: 'hospital_reached',
  VITALS_ALERT: 'vitals_alert',
  BLOOD_REQUEST: 'blood_request',
  INSURANCE_UPDATE: 'insurance_update',
  GENERAL: 'general',
};

/**
 * User Roles
 */
const UserRole = {
  PATIENT: 'patient',
  AMBULANCE_DRIVER: 'ambulance_driver',
  HOSPITAL_ADMIN: 'hospital_admin',
  ADMIN: 'admin',
};

/**
 * Vitals Alert Levels
 */
const VitalsAlertLevel = {
  NORMAL: 'normal',
  WARNING: 'warning',
  CRITICAL: 'critical',
};

/**
 * Blood Request Status
 */
const BloodRequestStatus = {
  PENDING: 'pending',
  MATCHED: 'matched',
  FULFILLED: 'fulfilled',
  CANCELLED: 'cancelled',
};

/**
 * Distance Limits (in km)
 */
const DistanceLimits = {
  AMBULANCE_SEARCH_RADIUS: 15,
  HOSPITAL_SEARCH_RADIUS: 20,
  BLOOD_BANK_SEARCH_RADIUS: 25,
};

module.exports = {
  EmergencyStatus,
  EmergencyType,
  AmbulanceStatus,
  BloodGroup,
  InsuranceStatus,
  InsuranceProvider,
  NotificationType,
  UserRole,
  VitalsAlertLevel,
  BloodRequestStatus,
  DistanceLimits,
};