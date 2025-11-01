const axios = require('axios');
const logger = require('../utils/logger.util');
const { calculateDistance, estimateTravelTime } = require('../utils/distance.util');

/**
 * Location Service - Google Maps Integration
 */
class LocationService {
  constructor() {
    this.apiKey = process.env.GOOGLE_MAPS_API_KEY;
    this.geocodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
    this.directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    this.placesUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  }

  /**
   * Get address from coordinates (Reverse Geocoding)
   */
  async getAddressFromCoordinates(latitude, longitude) {
    try {
      if (!this.apiKey) {
        logger.warn('Google Maps API key not configured');
        return {
          address: `${latitude}, ${longitude}`,
          city: 'Unknown',
          state: 'Unknown',
          pincode: null,
        };
      }

      const response = await axios.get(this.geocodeUrl, {
        params: {
          latlng: `${latitude},${longitude}`,
          key: this.apiKey,
        },
      });

      if (response.data.status === 'OK' && response.data.results.length > 0) {
        const result = response.data.results[0];
        const addressComponents = result.address_components;

        // Extract address parts
        const address = result.formatted_address;
        const city = this.extractComponent(addressComponents, 'locality') ||
                     this.extractComponent(addressComponents, 'administrative_area_level_2');
        const state = this.extractComponent(addressComponents, 'administrative_area_level_1');
        const pincode = this.extractComponent(addressComponents, 'postal_code');

        return {
          address,
          city,
          state,
          pincode,
          fullResponse: result,
        };
      }

      throw new Error('No results found');
    } catch (error) {
      logger.error('Geocoding error:', error);
      return {
        address: `${latitude}, ${longitude}`,
        city: 'Unknown',
        state: 'Unknown',
        pincode: null,
      };
    }
  }

  /**
   * Get coordinates from address (Forward Geocoding)
   */
  async getCoordinatesFromAddress(address) {
    try {
      if (!this.apiKey) {
        throw new Error('Google Maps API key not configured');
      }

      const response = await axios.get(this.geocodeUrl, {
        params: {
          address: address,
          key: this.apiKey,
        },
      });

      if (response.data.status === 'OK' && response.data.results.length > 0) {
        const location = response.data.results[0].geometry.location;
        return {
          latitude: location.lat,
          longitude: location.lng,
        };
      }

      throw new Error('Address not found');
    } catch (error) {
      logger.error('Forward geocoding error:', error);
      throw error;
    }
  }

  /**
   * Calculate route between two points
   */
  async getRoute(origin, destination, mode = 'driving') {
    try {
      if (!this.apiKey) {
        // Fallback: simple distance calculation
        const distance = calculateDistance(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude
        );

        return {
          distance: distance,
          duration: estimateTravelTime(distance),
          route: null,
        };
      }

      const response = await axios.get(this.directionsUrl, {
        params: {
          origin: `${origin.latitude},${origin.longitude}`,
          destination: `${destination.latitude},${destination.longitude}`,
          mode: mode, // driving, walking, bicycling, transit
          key: this.apiKey,
        },
      });

      if (response.data.status === 'OK' && response.data.routes.length > 0) {
        const route = response.data.routes[0];
        const leg = route.legs[0];

        return {
          distance: leg.distance.value / 1000, // Convert to km
          duration: Math.ceil(leg.duration.value / 60), // Convert to minutes
          route: {
            polyline: route.overview_polyline.points,
            steps: leg.steps.map(step => ({
              instruction: step.html_instructions.replace(/<[^>]*>/g, ''),
              distance: step.distance.text,
              duration: step.duration.text,
            })),
          },
        };
      }

      throw new Error('No route found');
    } catch (error) {
      logger.error('Route calculation error:', error);
      // Fallback calculation
      const distance = calculateDistance(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude
      );

      return {
        distance: distance,
        duration: estimateTravelTime(distance),
        route: null,
      };
    }
  }

  /**
   * Get ETA (Estimated Time of Arrival)
   */
  async getETA(origin, destination) {
    try {
      const route = await this.getRoute(origin, destination);

      const now = new Date();
      const eta = new Date(now.getTime() + route.duration * 60000); // Add minutes

      return {
        distance: route.distance,
        durationMinutes: route.duration,
        eta: eta,
        etaString: eta.toLocaleTimeString('en-IN', {
          hour: '2-digit',
          minute: '2-digit'
        }),
      };
    } catch (error) {
      logger.error('ETA calculation error:', error);
      throw error;
    }
  }

  /**
   * Find nearby places
   */
  async findNearbyPlaces(latitude, longitude, type, radiusMeters = 5000) {
    try {
      if (!this.apiKey) {
        throw new Error('Google Maps API key not configured');
      }

      const response = await axios.get(this.placesUrl, {
        params: {
          location: `${latitude},${longitude}`,
          radius: radiusMeters,
          type: type, // hospital, pharmacy, etc.
          key: this.apiKey,
        },
      });

      if (response.data.status === 'OK') {
        return response.data.results.map(place => ({
          name: place.name,
          address: place.vicinity,
          location: {
            latitude: place.geometry.location.lat,
            longitude: place.geometry.location.lng,
          },
          rating: place.rating || 0,
          isOpen: place.opening_hours?.open_now || false,
          placeId: place.place_id,
        }));
      }

      return [];
    } catch (error) {
      logger.error('Nearby places error:', error);
      return [];
    }
  }

  /**
   * Calculate distance matrix (multiple origins/destinations)
   */
  async calculateDistanceMatrix(origins, destinations) {
    const matrix = [];

    for (const origin of origins) {
      const row = [];
      for (const destination of destinations) {
        const distance = calculateDistance(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude
        );
        row.push({
          distance: distance,
          duration: estimateTravelTime(distance),
        });
      }
      matrix.push(row);
    }

    return matrix;
  }

  /**
   * Extract component from address components
   */
  extractComponent(components, type) {
    const component = components.find(c => c.types.includes(type));
    return component ? component.long_name : null;
  }

  /**
   * Validate coordinates
   */
  isValidCoordinates(latitude, longitude) {
    const lat = parseFloat(latitude);
    const lon = parseFloat(longitude);

    return (
      !isNaN(lat) &&
      !isNaN(lon) &&
      lat >= -90 &&
      lat <= 90 &&
      lon >= -180 &&
      lon <= 180
    );
  }

  /**
   * Format location for display
   */
  formatLocation(locationData) {
    if (locationData.address) {
      return locationData.address;
    }

    const parts = [];
    if (locationData.city) parts.push(locationData.city);
    if (locationData.state) parts.push(locationData.state);
    if (locationData.pincode) parts.push(locationData.pincode);

    return parts.join(', ') || `${locationData.latitude}, ${locationData.longitude}`;
  }
}

module.exports = new LocationService();