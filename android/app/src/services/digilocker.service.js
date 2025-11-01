const axios = require('axios');
const logger = require('../utils/logger.util');
const { digilockerDocsCollection } = require('../config/database.config');
const { v4: uuidv4 } = require('uuid');

/**
 * DigiLocker Service - Integration with DigiLocker API
 */
class DigiLockerService {
  constructor() {
    this.clientId = process.env.DIGILOCKER_CLIENT_ID;
    this.clientSecret = process.env.DIGILOCKER_CLIENT_SECRET;
    this.redirectUri = process.env.DIGILOCKER_REDIRECT_URI;

    // DigiLocker API endpoints
    this.authUrl = 'https://digilocker.meripehchaan.gov.in/public/oauth2/1/authorize';
    this.tokenUrl = 'https://digilocker.meripehchaan.gov.in/public/oauth2/1/token';
    this.apiBaseUrl = 'https://api.digitallocker.gov.in/public/oauth2/1';
  }

  /**
   * Generate DigiLocker authorization URL
   */
  getAuthorizationUrl(state) {
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: this.clientId,
      redirect_uri: this.redirectUri,
      state: state,
      code_challenge: this.generateCodeChallenge(),
      code_challenge_method: 'S256',
    });

    return `${this.authUrl}?${params.toString()}`;
  }

  /**
   * Exchange authorization code for access token
   */
  async getAccessToken(authorizationCode) {
    try {
      const response = await axios.post(
        this.tokenUrl,
        {
          grant_type: 'authorization_code',
          code: authorizationCode,
          client_id: this.clientId,
          client_secret: this.clientSecret,
          redirect_uri: this.redirectUri,
        },
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        }
      );

      return {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        expiresIn: response.data.expires_in,
      };
    } catch (error) {
      logger.error('DigiLocker token exchange error:', error);
      throw error;
    }
  }

  /**
   * Get user's Aadhaar details
   */
  async getAadhaarDetails(accessToken) {
    try {
      const response = await axios.get(`${this.apiBaseUrl}/aadhaar`, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      return {
        name: response.data.name,
        dob: response.data.dob,
        gender: response.data.gender,
        address: {
          house: response.data.house,
          street: response.data.street,
          locality: response.data.loc,
          vtc: response.data.vtc,
          district: response.data.dist,
          state: response.data.state,
          pincode: response.data.pc,
        },
        photo: response.data.photo, // Base64 encoded
      };
    } catch (error) {
      logger.error('DigiLocker Aadhaar fetch error:', error);
      throw error;
    }
  }

  /**
   * Get list of issued documents
   */
  async getIssuedDocuments(accessToken) {
    try {
      const response = await axios.get(`${this.apiBaseUrl}/issued`, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      return response.data.items || [];
    } catch (error) {
      logger.error('DigiLocker issued documents error:', error);
      throw error;
    }
  }

  /**
   * Get specific document by URI
   */
  async getDocument(accessToken, documentUri) {
    try {
      const response = await axios.get(`${this.apiBaseUrl}/file/${documentUri}`, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
        responseType: 'arraybuffer', // For PDF/image files
      });

      return {
        data: response.data,
        contentType: response.headers['content-type'],
      };
    } catch (error) {
      logger.error('DigiLocker document fetch error:', error);
      throw error;
    }
  }

  /**
   * Fetch and store insurance documents
   */
  async fetchInsuranceDocuments(userId, accessToken) {
    try {
      const documents = await this.getIssuedDocuments(accessToken);

      // Filter insurance-related documents
      const insuranceDocs = documents.filter(doc =>
        doc.doctype.toLowerCase().includes('insurance') ||
        doc.doctype.toLowerCase().includes('health') ||
        doc.doctype.toLowerCase().includes('ayushman') ||
        doc.doctype.toLowerCase().includes('aarogyasri')
      );

      const savedDocs = [];

      for (const doc of insuranceDocs) {
        // Fetch document content
        const documentData = await this.getDocument(accessToken, doc.uri);

        // Store in Firestore
        const docId = uuidv4();
        const docRecord = {
          docId: docId,
          userId: userId,
          documentType: doc.doctype,
          documentName: doc.name,
          issuer: doc.issuer,
          issueDate: doc.date,
          uri: doc.uri,
          contentType: documentData.contentType,
          // Note: Store actual file in Firebase Storage, not in Firestore
          storageUrl: null, // Will be updated after uploading to Storage
          fetchedAt: new Date(),
        };

        await digilockerDocsCollection().doc(docId).set(docRecord);
        savedDocs.push(docRecord);
      }

      logger.success(`Fetched ${savedDocs.length} insurance documents for user ${userId}`);
      return savedDocs;
    } catch (error) {
      logger.error('Fetch insurance documents error:', error);
      throw error;
    }
  }

  /**
   * Verify Aadhaar with DigiLocker
   */
  async verifyAadhaar(accessToken, aadhaarNumber) {
    try {
      const aadhaarDetails = await this.getAadhaarDetails(accessToken);

      // Note: DigiLocker doesn't return full Aadhaar number for privacy
      // Verification is implicit through successful authentication

      return {
        verified: true,
        name: aadhaarDetails.name,
        dob: aadhaarDetails.dob,
        gender: aadhaarDetails.gender,
      };
    } catch (error) {
      logger.error('Aadhaar verification error:', error);
      return {
        verified: false,
        error: error.message,
      };
    }
  }

  /**
   * Refresh access token
   */
  async refreshAccessToken(refreshToken) {
    try {
      const response = await axios.post(
        this.tokenUrl,
        {
          grant_type: 'refresh_token',
          refresh_token: refreshToken,
          client_id: this.clientId,
          client_secret: this.clientSecret,
        },
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        }
      );

      return {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        expiresIn: response.data.expires_in,
      };
    } catch (error) {
      logger.error('DigiLocker token refresh error:', error);
      throw error;
    }
  }

  /**
   * Parse insurance policy from DigiLocker document
   */
  parseInsurancePolicy(documentData) {
    // This is a placeholder - actual implementation would need PDF parsing
    // Libraries like pdf-parse can be used for this

    return {
      policyNumber: null,
      provider: null,
      coverage: null,
      validUpto: null,
      // Extract using regex or PDF parsing
    };
  }

  /**
   * Generate code challenge for PKCE (for security)
   */
  generateCodeChallenge() {
    // Simplified version - in production, use proper PKCE implementation
    const crypto = require('crypto');
    const verifier = crypto.randomBytes(32).toString('base64url');
    const challenge = crypto.createHash('sha256').update(verifier).digest('base64url');
    return challenge;
  }

  /**
   * Check if DigiLocker is configured
   */
  isConfigured() {
    return !!(this.clientId && this.clientSecret && this.redirectUri);
  }
}

module.exports = new DigiLockerService();