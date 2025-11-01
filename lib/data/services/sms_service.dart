import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/emergency_model.dart';
import '../models/user_model.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  // Check SMS permission
  Future<bool> checkSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  // Send emergency SMS to a single contact using url_launcher
  Future<bool> sendEmergencySms({
    required String phoneNumber,
    required String userName,
    required EmergencyLocation location,
    String? bloodGroup,
  }) async {
    try {
      // Check permission
      bool hasPermission = await checkSmsPermission();
      if (!hasPermission) {
        hasPermission = await requestSmsPermission();
      }

      // Create emergency message
      String message = _createEmergencyMessage(
        userName: userName,
        location: location,
        bloodGroup: bloodGroup,
      );

      // Open SMS composer
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print('SMS composer opened for $phoneNumber');
        return true;
      } else {
        print('Could not launch SMS composer');
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  // Send emergency SMS to multiple contacts
  Future<List<String>> sendEmergencySmsToContacts({
    required List<EmergencyContact> contacts,
    required String userName,
    required EmergencyLocation location,
    String? bloodGroup,
  }) async {
    List<String> successfulContacts = [];

    // Create emergency message
    String message = _createEmergencyMessage(
      userName: userName,
      location: location,
      bloodGroup: bloodGroup,
    );

    try {
      // Get all phone numbers
      List<String> phoneNumbers = contacts.map((c) => c.phone).toList();
      String recipientsString = phoneNumbers.join(';');

      // Open SMS composer with multiple recipients
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipientsString,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        successfulContacts = phoneNumbers;
        print('SMS composer opened for ${phoneNumbers.length} contacts');
      }
    } catch (e) {
      print('Error sending bulk SMS: $e');
    }

    return successfulContacts;
  }

  // Create emergency message text
  String _createEmergencyMessage({
    required String userName,
    required EmergencyLocation location,
    String? bloodGroup,
  }) {
    String message = '🚨 EMERGENCY ALERT 🚨\n\n';
    message += '$userName needs immediate help!\n\n';

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      message += 'Blood Group: $bloodGroup\n';
    }

    message += '\n📍 Location:\n';

    if (location.address != null) {
      message += '${location.address}\n';
    }

    message += 'Lat: ${location.latitude.toStringAsFixed(6)}\n';
    message += 'Long: ${location.longitude.toStringAsFixed(6)}\n';
    message += '\n🗺️ Google Maps:\n';
    message += location.mapsUrl;
    message += '\n\nPlease contact immediately or reach the location.';
    message += '\n\n- ArogyaRaksha AI';

    return message;
  }

  // Send update SMS (ambulance assigned, etc.)
  Future<bool> sendUpdateSms({
    required String phoneNumber,
    required String updateMessage,
  }) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': updateMessage},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending update SMS: $e');
      return false;
    }
  }

  // Send ambulance details to contacts
  Future<void> sendAmbulanceDetailsSms({
    required List<String> contactNumbers,
    required String ambulanceNumber,
    required String driverName,
    required String driverPhone,
  }) async {
    String message = '🚑 AMBULANCE ASSIGNED\n\n';
    message += 'Ambulance: $ambulanceNumber\n';
    message += 'Driver: $driverName\n';
    message += 'Driver Contact: $driverPhone\n';
    message += '\nAmbulance is on the way!\n';
    message += '- ArogyaRaksha AI';

    try {
      String recipientsString = contactNumbers.join(';');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipientsString,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      print('Error sending ambulance details: $e');
    }
  }

  // Send hospital details to contacts
  Future<void> sendHospitalDetailsSms({
    required List<String> contactNumbers,
    required String hospitalName,
    required String hospitalPhone,
    required EmergencyLocation hospitalLocation,
  }) async {
    String message = '🏥 HOSPITAL UPDATE\n\n';
    message += 'Hospital: $hospitalName\n';
    message += 'Contact: $hospitalPhone\n';

    if (hospitalLocation.address != null) {
      message += 'Address: ${hospitalLocation.address}\n';
    }

    message += '\nLocation: ${hospitalLocation.mapsUrl}\n';
    message += '- ArogyaRaksha AI';

    try {
      String recipientsString = contactNumbers.join(';');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipientsString,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      print('Error sending hospital details: $e');
    }
  }

  // Call emergency contact using url_launcher
  Future<void> callEmergencyContact(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        print('Could not launch phone dialer');
      }
    } catch (e) {
      print('Error opening dialer: $e');
    }
  }

  // Open SMS composer (general purpose)
  Future<void> openSmsComposer({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        print('Could not launch SMS composer');
      }
    } catch (e) {
      print('Error opening SMS composer: $e');
    }
  }

  // Send SMS to multiple recipients
  Future<bool> sendSmsToMultiple({
    required List<String> recipients,
    required String message,
  }) async {
    try {
      String recipientsString = recipients.join(';');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipientsString,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
}