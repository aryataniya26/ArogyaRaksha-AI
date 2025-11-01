require('dotenv').config();
const AmbulanceModel = require('../src/models/ambulance.model');
const logger = require('../src/utils/logger.util');

const sampleAmbulances = [
  {
    vehicleNumber: 'TS09AB1234',
    type: 'basic',
    driverInfo: {
      name: 'Raju Kumar',
      phone: '+919876501234',
      licenseNumber: 'DL1234567890',
    },
    location: {
      latitude: 17.4100,
      longitude: 78.4800,
      address: 'Near JNTU, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: false,
      defibrillator: false,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: '108',
    providerContact: '108',
    rating: 4.2,
  },
  {
    vehicleNumber: 'TS09CD5678',
    type: 'advanced',
    driverInfo: {
      name: 'Mohammed Ali',
      phone: '+919876502345',
      licenseNumber: 'DL2345678901',
    },
    location: {
      latitude: 17.4450,
      longitude: 78.3489,
      address: 'Gachibowli, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: true,
      defibrillator: true,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: 'private',
    providerContact: '+919876500000',
    rating: 4.5,
  },
  {
    vehicleNumber: 'TS09EF9012',
    type: 'ICU',
    driverInfo: {
      name: 'Suresh Reddy',
      phone: '+919876503456',
      licenseNumber: 'DL3456789012',
    },
    location: {
      latitude: 17.4239,
      longitude: 78.4738,
      address: 'Ameerpet, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: true,
      defibrillator: true,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: 'private',
    providerContact: '+919876500001',
    rating: 4.8,
  },
  {
    vehicleNumber: 'TS09GH3456',
    type: 'basic',
    driverInfo: {
      name: 'Lakshman Rao',
      phone: '+919876504567',
      licenseNumber: 'DL4567890123',
    },
    location: {
      latitude: 17.3850,
      longitude: 78.4867,
      address: 'Afzal Gunj, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: false,
      defibrillator: false,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: '108',
    providerContact: '108',
    rating: 4.0,
  },
  {
    vehicleNumber: 'TS09IJ7890',
    type: 'advanced',
    driverInfo: {
      name: 'Ramesh Babu',
      phone: '+919876505678',
      licenseNumber: 'DL5678901234',
    },
    location: {
      latitude: 17.4326,
      longitude: 78.4071,
      address: 'Somajiguda, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: true,
      defibrillator: true,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: 'private',
    providerContact: '+919876500002',
    rating: 4.6,
  },
  {
    vehicleNumber: 'TS09KL2345',
    type: 'basic',
    driverInfo: {
      name: 'Vijay Kumar',
      phone: '+919876506789',
      licenseNumber: 'DL6789012345',
    },
    location: {
      latitude: 17.4505,
      longitude: 78.3808,
      address: 'Kukatpally, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: false,
      defibrillator: false,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: '108',
    providerContact: '108',
    rating: 4.1,
  },
  {
    vehicleNumber: 'TS09MN6789',
    type: 'ICU',
    driverInfo: {
      name: 'Srinivas Reddy',
      phone: '+919876507890',
      licenseNumber: 'DL7890123456',
    },
    location: {
      latitude: 17.3616,
      longitude: 78.4747,
      address: 'Charminar, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: true,
      defibrillator: true,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: 'private',
    providerContact: '+919876500003',
    rating: 4.7,
  },
  {
    vehicleNumber: 'TS09OP1234',
    type: 'basic',
    driverInfo: {
      name: 'Naresh Kumar',
      phone: '+919876508901',
      licenseNumber: 'DL8901234567',
    },
    location: {
      latitude: 17.4909,
      longitude: 78.3967,
      address: 'Miyapur, Hyderabad',
    },
    status: 'available',
    facilities: {
      oxygen: true,
      ventilator: false,
      defibrillator: false,
      bloodPressureMonitor: true,
      firstAidKit: true,
      stretcher: true,
    },
    provider: '108',
    providerContact: '108',
    rating: 3.9,
  },
];

async function seedAmbulances() {
  try {
    logger.info('Starting ambulance seeding...');

    for (const ambulanceData of sampleAmbulances) {
      await AmbulanceModel.create(ambulanceData);
      logger.success(`✅ Added: ${ambulanceData.vehicleNumber} (${ambulanceData.type})`);
    }

    logger.success(`\n🎉 Successfully seeded ${sampleAmbulances.length} ambulances!`);
    process.exit(0);
  } catch (error) {
    logger.error('Error seeding ambulances:', error);
    process.exit(1);
  }
}

seedAmbulances();