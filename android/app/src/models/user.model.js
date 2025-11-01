const { usersCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');

/**
 * User Model Schema
 */
class UserModel {
  static collectionName = 'users';

  /**
   * Create new user profile
   */
  static async create(userData) {
    const userId = userData.uid || uuidv4();

    const user = {
      uid: userId,
      email: userData.email || null,
      phoneNumber: userData.phoneNumber || null,
      name: userData.name || '',
      age: userData.age || null,
      gender: userData.gender || null, // male, female, other
      bloodGroup: userData.bloodGroup || null, // A+, B+, O+, AB+, etc.
      aadhaar: userData.aadhaar || null, // Masked for privacy
      address: {
        line1: userData.address?.line1 || '',
        line2: userData.address?.line2 || '',
        city: userData.address?.city || '',
        state: userData.address?.state || '',
        pincode: userData.address?.pincode || '',
      },
      location: {
        latitude: userData.location?.latitude || null,
        longitude: userData.location?.longitude || null,
      },
      emergencyContacts: userData.emergencyContacts || [], // Array of {name, phone, relation}
      medicalHistory: {
        allergies: userData.medicalHistory?.allergies || [],
        chronicDiseases: userData.medicalHistory?.chronicDiseases || [],
        currentMedications: userData.medicalHistory?.currentMedications || [],
        surgeries: userData.medicalHistory?.surgeries || [],
        disabilities: userData.medicalHistory?.disabilities || [],
      },
      insurance: {
        hasInsurance: userData.insurance?.hasInsurance || false,
        provider: userData.insurance?.provider || null, // ayushman_bharat, aarogyasri, private
        policyNumber: userData.insurance?.policyNumber || null,
        validUpto: userData.insurance?.validUpto || null,
        coverage: userData.insurance?.coverage || 0,
        isVerified: userData.insurance?.isVerified || false,
      },
      profilePicture: userData.profilePicture || null,
      language: userData.language || 'english', // english, hindi, telugu
      role: userData.role || 'patient', // patient, ambulance_driver, hospital_admin
      isActive: userData.isActive !== undefined ? userData.isActive : true,
      deviceTokens: userData.deviceTokens || [], // FCM tokens for notifications
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await usersCollection().doc(userId).set(user);
    return { id: userId, ...user };
  }

  /**
   * Get user by ID
   */
  static async getById(userId) {
    const doc = await usersCollection().doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  }

  /**
   * Update user profile
   */
  static async update(userId, updateData) {
    const updates = {
      ...updateData,
      updatedAt: new Date(),
    };

    await usersCollection().doc(userId).update(updates);
    return await this.getById(userId);
  }

  /**
   * Add emergency contact
   */
  static async addEmergencyContact(userId, contact) {
    const user = await this.getById(userId);
    const emergencyContacts = user.emergencyContacts || [];

    emergencyContacts.push({
      id: uuidv4(),
      name: contact.name,
      phone: contact.phone,
      relation: contact.relation,
      addedAt: new Date(),
    });

    await this.update(userId, { emergencyContacts });
    return emergencyContacts;
  }

  /**
   * Update device token for push notifications
   */
  static async updateDeviceToken(userId, token) {
    const user = await this.getById(userId);
    const deviceTokens = user.deviceTokens || [];

    if (!deviceTokens.includes(token)) {
      deviceTokens.push(token);
      await this.update(userId, { deviceTokens });
    }

    return deviceTokens;
  }

  /**
   * Delete user
   */
  static async delete(userId) {
    await usersCollection().doc(userId).delete();
    return true;
  }
}

module.exports = UserModel;