require('dotenv').config();
const { BloodBankModel } = require('../src/models/blood.model');
const logger = require('../src/utils/logger.util');

const sampleBloodBanks = [
  {
    name: 'Red Cross Blood Bank',
    contact: {
      phone: '+919876540001',
      emergencyPhone: '+919876540001',
      email: 'redcross@hyderabad.org',
    },
    location: {
      latitude: 17.4065,
      longitude: 78.4772,
      address: 'Jubilee Hills, Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500033',
    },
    bloodAvailability: {
      'A+': 25,
      'A-': 8,
      'B+': 30,
      'B-': 5,
      'O+': 40,
      'O-': 12,
      'AB+': 15,
      'AB-': 3,
    },
    operatingHours: {
      is24x7: true,
      timings: '24x7',
    },
    facilities: {
      bloodTesting: true,
      componentSeparation: true,
      bloodStorage: true,
    },
    type: 'standalone',
    isGovernment: false,
  },
  {
    name: 'Gandhi Hospital Blood Bank',
    hospitalName: 'Gandhi Hospital',
    contact: {
      phone: '+919123456788',
      emergencyPhone: '+919123456788',
      email: 'bloodbank@gandhi.gov.in',
    },
    location: {
      latitude: 17.4505,
      longitude: 78.4954,
      address: 'Musheerabad, Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500020',
    },
    bloodAvailability: {
      'A+': 35,
      'A-': 10,
      'B+': 40,
      'B-': 8,
      'O+': 50,
      'O-': 15,
      'AB+': 20,
      'AB-': 5,
    },
    operatingHours: {
      is24x7: true,
      timings: '24x7',
    },
    facilities: {
      bloodTesting: true,
      componentSeparation: true,
      bloodStorage: true,
    },
    type: 'hospital',
    isGovernment: true,
  },
  {
    name: 'Apollo Blood Bank',
    hospitalName: 'Apollo Hospital',
    contact: {
      phone: '+919876543211',
      emergencyPhone: '+919876543211',
      email: 'bloodbank@apollo.com',
    },
    location: {
      latitude: 17.4065,
      longitude: 78.4772,
      address: 'Jubilee Hills, Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500033',
    },
    bloodAvailability: {
      'A+': 28,
      'A-': 9,
      'B+': 32,
      'B-': 6,
      'O+': 45,
      'O-': 14,
      'AB+': 18,
      'AB-': 4,
    },
    operatingHours: {
      is24x7: true,
      timings: '24x7',
    },
    facilities: {
      bloodTesting: true,
      componentSeparation: true,
      bloodStorage: true,
    },
    type: 'hospital',
    isGovernment: false,
  },
  {
    name: 'Osmania Blood Bank',
    hospitalName: 'Osmania General Hospital',
    contact: {
      phone: '+919100200301',
      emergencyPhone: '+919100200301',
      email: 'bloodbank@osmania.gov.in',
    },
    location: {
      latitude: 17.3850,
      longitude: 78.4867,
      address: 'Afzal Gunj, Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500012',
    },
    bloodAvailability: {
      'A+': 45,
      'A-': 12,
      'B+': 50,
      'B-': 10,
      'O+': 60,
      'O-': 18,
      'AB+': 25,
      'AB-': 7,
    },
    operatingHours: {
      is24x7: true,
      timings: '24x7',
    },
    facilities: {
      bloodTesting: true,
      componentSeparation: true,
      bloodStorage: true,
    },
    type: 'hospital',
    isGovernment: true,
  },
  {
    name: 'Yashoda Blood Bank',
    hospitalName: 'Yashoda Hospital',
    contact: {
      phone: '+919988776656',
      emergencyPhone: '+919988776656',
      email: 'bloodbank@yashoda.com',
    },
    location: {
      latitude: 17.4326,
      longitude: 78.4071,
      address: 'Somajiguda, Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500082',
    },
    bloodAvailability: {
      'A+': 22,
      'A-': 7,
      'B+': 28,
      'B-': 5,
      'O+': 38,
      'O-': 11,
      'AB+': 16,
      'AB-': 3,
    },
    operatingHours: {
      is24x7: false,
      timings: '8:00 AM - 8:00 PM',
    },
    facilities: {
      bloodTesting: true,
      componentSeparation: true,
      bloodStorage: true,
    },
    type: 'hospital',
    isGovernment: false,
  },
  {
    name: 'KIMS Blood Bank',
    hospitalName: 'KIMS Hospital',
    contact: {
      phone: '+919876512346',
      emergencyPhone: '+919876512346',
      email: 'bloodbank@kims.com',
    },
    location: {
      latitude: 17.4320,
      longitude: 78.3897,
      address: 'Kondapur, Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500084',
    },
    bloodAvailability: {
      'A+': 30,
      'A-': 8,
      'B+': 35,
      'B-': 6,
      'O+': 42,
      'O-': 13,
      'AB+': 19,
      'AB-': 4,
    },
    operatingHours: {
      is24x7: true,
      timings: '24x7',
    },
    facilities: {
      bloodTesting: true,
      componentSeparation: true,
      bloodStorage: true,
    },
    type: 'hospital',
    isGovernment: false,
  },
];

async function seedBloodBanks() {
  try {
    logger.info('Starting blood bank seeding...');

    for (const bloodBankData of sampleBloodBanks) {
      await BloodBankModel.create(bloodBankData);
      logger.success(`✅ Added: ${bloodBankData.name}`);
    }

    logger.success(`\n🎉 Successfully seeded ${sampleBloodBanks.length} blood banks!`);
    process.exit(0);
  } catch (error) {
    logger.error('Error seeding blood banks:', error);
    process.exit(1);
  }
}

seedBloodBanks();