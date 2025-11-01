const { db } = require('./firebase.config');

// Firestore Collections
const Collections = {
  USERS: 'users',
  EMERGENCIES: 'emergencies',
  AMBULANCES: 'ambulances',
  HOSPITALS: 'hospitals',
  INSURANCE: 'insurance',
  VITALS: 'vitals',
  BLOOD_BANKS: 'blood_banks',
  BLOOD_REQUESTS: 'blood_requests',
  NOTIFICATIONS: 'notifications',
  EMERGENCY_CONTACTS: 'emergency_contacts',
  MEDICAL_HISTORY: 'medical_history',
  DIGILOCKER_DOCS: 'digilocker_documents',
};

// Collection References
const getCollection = (collectionName) => {
  return db.collection(collectionName);
};

// Users Collection
const usersCollection = () => getCollection(Collections.USERS);

// Emergencies Collection
const emergenciesCollection = () => getCollection(Collections.EMERGENCIES);

// Ambulances Collection
const ambulancesCollection = () => getCollection(Collections.AMBULANCES);

// Hospitals Collection
const hospitalsCollection = () => getCollection(Collections.HOSPITALS);

// Insurance Collection
const insuranceCollection = () => getCollection(Collections.INSURANCE);

// Vitals Collection
const vitalsCollection = () => getCollection(Collections.VITALS);

// Blood Banks Collection
const bloodBanksCollection = () => getCollection(Collections.BLOOD_BANKS);

// Blood Requests Collection
const bloodRequestsCollection = () => getCollection(Collections.BLOOD_REQUESTS);

// Notifications Collection
const notificationsCollection = () => getCollection(Collections.NOTIFICATIONS);

// Emergency Contacts Collection
const emergencyContactsCollection = () => getCollection(Collections.EMERGENCY_CONTACTS);

// Medical History Collection
const medicalHistoryCollection = () => getCollection(Collections.MEDICAL_HISTORY);

// DigiLocker Documents Collection
const digilockerDocsCollection = () => getCollection(Collections.DIGILOCKER_DOCS);

module.exports = {
  db,
  Collections,
  getCollection,
  usersCollection,
  emergenciesCollection,
  ambulancesCollection,
  hospitalsCollection,
  insuranceCollection,
  vitalsCollection,
  bloodBanksCollection,
  bloodRequestsCollection,
  notificationsCollection,
  emergencyContactsCollection,
  medicalHistoryCollection,
  digilockerDocsCollection,
};