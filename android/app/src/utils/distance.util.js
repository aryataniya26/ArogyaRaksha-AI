/**
 * Calculate distance between two coordinates using Haversine formula
 * @param {number} lat1 - Latitude of point 1
 * @param {number} lon1 - Longitude of point 1
 * @param {number} lat2 - Latitude of point 2
 * @param {number} lon2 - Longitude of point 2
 * @returns {number} - Distance in kilometers
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Radius of Earth in kilometers

  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;

  return parseFloat(distance.toFixed(2));
};

/**
 * Convert degrees to radians
 */
const toRadians = (degrees) => {
  return degrees * (Math.PI / 180);
};

/**
 * Find nearest item from a list based on location
 * @param {Object} userLocation - {latitude, longitude}
 * @param {Array} items - Array of items with location property
 * @returns {Array} - Sorted array of items with distance
 */
const findNearest = (userLocation, items) => {
  return items
    .map(item => {
      const distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        item.location.latitude,
        item.location.longitude
      );

      return {
        ...item,
        distance,
      };
    })
    .sort((a, b) => a.distance - b.distance);
};

/**
 * Filter items within a radius
 * @param {Object} userLocation - {latitude, longitude}
 * @param {Array} items - Array of items with location
 * @param {number} radiusKm - Radius in kilometers
 * @returns {Array} - Filtered items within radius
 */
const filterByRadius = (userLocation, items, radiusKm) => {
  return items.filter(item => {
    const distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      item.location.latitude,
      item.location.longitude
    );

    return distance <= radiusKm;
  });
};

/**
 * Estimate travel time (rough estimate: 40 km/hr average)
 * @param {number} distanceKm - Distance in kilometers
 * @returns {number} - Estimated time in minutes
 */
const estimateTravelTime = (distanceKm) => {
  const averageSpeedKmh = 40; // Average speed in city
  const timeHours = distanceKm / averageSpeedKmh;
  const timeMinutes = Math.ceil(timeHours * 60);

  return timeMinutes;
};

module.exports = {
  calculateDistance,
  findNearest,
  filterByRadius,
  estimateTravelTime,
};