import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Personal Details Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Medical Info Controllers
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _disabilitiesController = TextEditingController();

  // Insurance Controllers
  final _insuranceProviderController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _coverageController = TextEditingController();
  final _validTillController = TextEditingController();

  // Emergency Contacts List
  List<EmergencyContact> _emergencyContacts = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Future<void> _loadUserData() async {
  //   try {
  //     final userId = _auth.currentUser?.uid;
  //     if (userId == null) return;
  //
  //     final doc = await _firestore.collection('users').doc(userId).get();
  //
  //     if (doc.exists && mounted) {
  //       final userData = UserModel.fromJson(doc.data()!);
  //
  //       setState(() {
  //         // Personal Details
  //         _nameController.text = userData.name;
  //         _ageController.text = userData.age.toString();
  //         _addressController.text = userData.address ?? '';
  //         _phoneController.text = userData.phone;
  //         _aadhaarController.text = userData.aadhaar ?? '';
  //         _selectedBloodGroup = userData.bloodGroup.isNotEmpty ? userData.bloodGroup : null;
  //         _selectedGender = userData.gender;
  //
  //         // Medical Info
  //         _allergiesController.text = userData.medicalInfo.allergies.join(', ');
  //         _conditionsController.text = userData.medicalInfo.conditions.join(', ');
  //         _medicationsController.text = userData.medicalInfo.medications.join(', ');
  //         _chronicDiseasesController.text = userData.medicalInfo.chronicDiseases.join(', ');
  //         _disabilitiesController.text = userData.medicalInfo.disabilities ?? '';
  //
  //         // Insurance
  //         if (userData.insurance != null) {
  //           _insuranceProviderController.text = userData.insurance!.provider;
  //           _policyNumberController.text = userData.insurance!.policyNumber;
  //           _coverageController.text = userData.insurance!.coverage ?? '';
  //           _validTillController.text = userData.insurance!.validTill ?? '';
  //         }
  //
  //         // Emergency Contacts
  //         _emergencyContacts = List.from(userData.emergencyContacts);
  //
  //         _isLoadingData = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading user data: $e');
  //     if (mounted) {
  //       setState(() => _isLoadingData = false);
  //     }
  //   }
  // }
  Future<void> _loadUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        // 🔹 Create a blank default user document if it doesn’t exist
        await docRef.set({
          'uid': userId,
          'email': _auth.currentUser?.email ?? '',
          'name': _auth.currentUser?.displayName ?? '',
          'phone': '',
          'address': '',
          'bloodGroup': '',
          'gender': '',
          'age': 0,
          'aadhaar': '',
          'medicalInfo': {
            'allergies': [],
            'conditions': [],
            'medications': [],
            'chronicDiseases': [],
            'disabilities': '',
          },
          'insurance': null,
          'emergencyContacts': [],
        });
      }

      final freshDoc = await docRef.get();
      if (freshDoc.exists && mounted) {
        final userData = UserModel.fromJson(freshDoc.data()!);

        setState(() {
          // Personal Details
          _nameController.text = userData.name;
          _ageController.text = userData.age.toString();
          _addressController.text = userData.address ?? '';
          _phoneController.text = userData.phone;
          _aadhaarController.text = userData.aadhaar ?? '';
          _selectedBloodGroup = userData.bloodGroup.isNotEmpty ? userData.bloodGroup : null;
          _selectedGender = userData.gender;

          // Medical Info
          _allergiesController.text = userData.medicalInfo.allergies.join(', ');
          _conditionsController.text = userData.medicalInfo.conditions.join(', ');
          _medicationsController.text = userData.medicalInfo.medications.join(', ');
          _chronicDiseasesController.text = userData.medicalInfo.chronicDiseases.join(', ');
          _disabilitiesController.text = userData.medicalInfo.disabilities ?? '';

          // Insurance
          if (userData.insurance != null) {
            _insuranceProviderController.text = userData.insurance!.provider;
            _policyNumberController.text = userData.insurance!.policyNumber;
            _coverageController.text = userData.insurance!.coverage ?? '';
            _validTillController.text = userData.insurance!.validTill ?? '';
          }

          // Emergency Contacts
          _emergencyContacts = List.from(userData.emergencyContacts);

          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }





  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _chronicDiseasesController.dispose();
    _disabilitiesController.dispose();
    _insuranceProviderController.dispose();
    _policyNumberController.dispose();
    _coverageController.dispose();
    _validTillController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userId = _auth.currentUser?.uid;
        if (userId == null) return;

        // Create UserModel
        final userModel = UserModel(
          uid: userId,
          email: _auth.currentUser!.email!,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _selectedGender,
          aadhaar: _aadhaarController.text.trim(),
          bloodGroup: _selectedBloodGroup ?? '',
          age: int.tryParse(_ageController.text.trim()) ?? 0,
          address: _addressController.text.trim(),
          emergencyContacts: _emergencyContacts,
          medicalInfo: MedicalInfo(
            allergies: _allergiesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            conditions: _conditionsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            medications: _medicationsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            chronicDiseases: _chronicDiseasesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            disabilities: _disabilitiesController.text.trim().isNotEmpty ? _disabilitiesController.text.trim() : null,
          ),
          insurance: (_insuranceProviderController.text.trim().isNotEmpty && _policyNumberController.text.trim().isNotEmpty)
              ? InsuranceInfo(
            provider: _insuranceProviderController.text.trim(),
            policyNumber: _policyNumberController.text.trim(),
            coverage: _coverageController.text.trim().isNotEmpty ? _coverageController.text.trim() : null,
            validTill: _validTillController.text.trim().isNotEmpty ? _validTillController.text.trim() : null,
          )
              : null,
        );

        await _firestore.collection('users').doc(userId).set(
          userModel.toJson(),
          SetOptions(merge: true),
        );

        await _auth.currentUser?.updateDisplayName(_nameController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('Error updating profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _addEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => _EmergencyContactDialog(
        onSave: (contact) {
          setState(() {
            _emergencyContacts.add(contact);
          });
        },
      ),
    );
  }

  void _editEmergencyContact(int index) {
    showDialog(
      context: context,
      builder: (context) => _EmergencyContactDialog(
        contact: _emergencyContacts[index],
        onSave: (contact) {
          setState(() {
            _emergencyContacts[index] = contact;
          });
        },
      ),
    );
  }

  void _deleteEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                          image: DecorationImage(
                            image: NetworkImage(_auth.currentUser?.photoURL ?? 'https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Handle image picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Image picker coming soon!')),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Personal Details
                _buildSectionTitle('Personal Details'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your name',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'Enter age',
                        prefixIcon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdown('Gender', _selectedGender, _genders, (val) => setState(() => _selectedGender = val))),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildDropdown('Blood Group', _selectedBloodGroup, _bloodGroups, (val) => setState(() => _selectedBloodGroup = val))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        hint: 'Phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter your address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _aadhaarController,
                  label: 'Aadhaar Number (Optional)',
                  hint: 'Enter Aadhaar number',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // Emergency Contacts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Emergency Contacts'),
                    IconButton(
                      onPressed: _addEmergencyContact,
                      icon: const Icon(Icons.add_circle, color: AppColors.primaryTeal),
                      tooltip: 'Add Contact',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_emergencyContacts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Text('No emergency contacts added yet', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ..._emergencyContacts.asMap().entries.map((entry) {
                    int index = entry.key;
                    EmergencyContact contact = entry.value;
                    return _buildEmergencyContactCard(context, contact, index);
                  }),

                const SizedBox(height: 32),

                // Medical History
                _buildSectionTitle('Medical History'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _allergiesController,
                  label: 'Allergies (comma separated)',
                  hint: 'e.g., Peanuts, Penicillin',
                  prefixIcon: Icons.medical_information_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _conditionsController,
                  label: 'Medical Conditions (comma separated)',
                  hint: 'e.g., Diabetes, Hypertension',
                  prefixIcon: Icons.local_hospital_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _medicationsController,
                  label: 'Current Medications (comma separated)',
                  hint: 'e.g., Aspirin, Metformin',
                  prefixIcon: Icons.medication_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _chronicDiseasesController,
                  label: 'Chronic Diseases (comma separated)',
                  hint: 'e.g., Asthma, Heart Disease',
                  prefixIcon: Icons.sick_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _disabilitiesController,
                  label: 'Disabilities (if any)',
                  hint: 'Enter disabilities',
                  prefixIcon: Icons.accessible_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Insurance Details
                _buildSectionTitle('Insurance Details'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _insuranceProviderController,
                  label: 'Insurance Provider',
                  hint: 'e.g., Star Health, HDFC Ergo',
                  prefixIcon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _policyNumberController,
                  label: 'Policy Number',
                  hint: 'Enter policy number',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _coverageController,
                        label: 'Coverage Amount',
                        hint: 'e.g., Rs. 5,00,000',
                        prefixIcon: Icons.attach_money_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _validTillController,
                        label: 'Valid Till',
                        hint: 'DD/MM/YYYY',
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  isOutlined: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label'),
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
              items: items.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context, EmergencyContact contact, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: contact.isPrimary ? AppColors.primaryTeal : Colors.grey[300]!, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Primary', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(contact.relation, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(contact.phone, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryTeal),
            onPressed: () => _editEmergencyContact(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteEmergencyContact(index),
          ),
        ],
      ),
    );
  }
}

// Emergency Contact Dialog
class _EmergencyContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onSave;

  const _EmergencyContactDialog({this.contact, required this.onSave});

  @override
  State<_EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<_EmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _relationController.text = widget.contact!.relation;
      _phoneController.text = widget.contact!.phone;
      _isPrimary = widget.contact!.isPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Emergency Contact' : 'Edit Emergency Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relation', prefixIcon: Icon(Icons.family_restroom)),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Primary Contact'),
                value: _isPrimary,
                onChanged: (value) => setState(() => _isPrimary = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(EmergencyContact(
                name: _nameController.text.trim(),
                relation: _relationController.text.trim(),
                phone: _phoneController.text.trim(),
                isPrimary: _isPrimary,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_text_field.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   final _nameController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _allergiesController = TextEditingController();
//   final _insuranceProviderController = TextEditingController();
//   final _policyIdController = TextEditingController();
//
//   String? _selectedBloodGroup;
//   final List<String> _bloodGroups = [
//     'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
//   ];
//
//   bool _isLoading = false;
//   bool _isLoadingData = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;
//
//       final doc = await _firestore.collection('users').doc(userId).get();
//
//       if (doc.exists && mounted) {
//         final data = doc.data()!;
//         setState(() {
//           _nameController.text = data['name'] ?? '';
//           _ageController.text = data['age']?.toString() ?? '';
//           _addressController.text = data['address'] ?? '';
//           _phoneController.text = data['phone'] ?? '';
//           _selectedBloodGroup = data['bloodGroup'];
//
//           // Handle nested maps safely
//           if (data['medicalHistory'] is Map) {
//             _allergiesController.text = data['medicalHistory']['allergies'] ?? '';
//           }
//           if (data['insurance'] is Map) {
//             _insuranceProviderController.text = data['insurance']['provider'] ?? '';
//             _policyIdController.text = data['insurance']['policyId'] ?? '';
//           }
//
//           _isLoadingData = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading user data: $e');
//       if (mounted) {
//         setState(() => _isLoadingData = false);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     _allergiesController.dispose();
//     _insuranceProviderController.dispose();
//     _policyIdController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleSave() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//
//       try {
//         final userId = _auth.currentUser?.uid;
//         if (userId == null) return;
//
//         await _firestore.collection('users').doc(userId).update({
//           'name': _nameController.text.trim(),
//           'age': int.tryParse(_ageController.text.trim()) ?? 0,
//           'bloodGroup': _selectedBloodGroup ?? '',
//           'address': _addressController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'medicalHistory': {
//             'allergies': _allergiesController.text.trim(),
//           },
//           'insurance': {
//             'provider': _insuranceProviderController.text.trim(),
//             'policyId': _policyIdController.text.trim(),
//           },
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//
//         await _auth.currentUser?.updateDisplayName(_nameController.text.trim());
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Profile updated successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context, true);
//         }
//       } catch (e) {
//         print('Error updating profile: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to update profile'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() => _isLoading = false);
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoadingData) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Edit Profile')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Picture Section
//                 Center(
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Theme.of(context).primaryColor, width: 3),
//                           image: const DecorationImage(
//                             image: NetworkImage('https://via.placeholder.com/150'),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: GestureDetector(
//                           onTap: () {
//                             // TODO: Handle image picker
//                           },
//                           child: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).primaryColor,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 3),
//                             ),
//                             child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Personal Details
//                 Text('Personal Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//
//                 CustomTextField(
//                   controller: _nameController,
//                   label: 'Full Name',
//                   hint: 'Enter your name',
//                   prefixIcon: Icons.person_outlined,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
//                 ),
//                 const SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextField(
//                         controller: _ageController,
//                         label: 'Age',
//                         hint: 'Enter age',
//                         prefixIcon: Icons.cake_outlined,
//                         keyboardType: TextInputType.number,
//                         validator: (value) => value == null || value.isEmpty ? 'Required' : null,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Blood Group', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey[300]!),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: _selectedBloodGroup,
//                                 isExpanded: true,
//                                 hint: const Text('Select'),
//                                 icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
//                                 items: _bloodGroups.map((String value) {
//                                   return DropdownMenuItem<String>(value: value, child: Text(value));
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() => _selectedBloodGroup = newValue);
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//
//                 CustomTextField(
//                   controller: _addressController,
//                   label: 'Address',
//                   hint: 'Enter your address',
//                   prefixIcon: Icons.location_on_outlined,
//                   maxLines: 2,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
//                 ),
//                 const SizedBox(height: 16),
//
//                 CustomTextField(
//                   controller: _phoneController,
//                   label: 'Contact Number',
//                   hint: 'Enter phone number',
//                   prefixIcon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Medical History
//                 Text('Medical History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//
//                 CustomTextField(
//                   controller: _allergiesController,
//                   label: 'Allergies',
//                   hint: 'Enter any allergies',
//                   prefixIcon: Icons.medical_information_outlined,
//                   maxLines: 2,
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Insurance Details
//                 Text('Insurance Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//
//                 CustomTextField(
//                   controller: _insuranceProviderController,
//                   label: 'Insurance Provider',
//                   hint: 'Enter provider name',
//                   prefixIcon: Icons.business_outlined,
//                 ),
//                 const SizedBox(height: 16),
//
//                 CustomTextField(
//                   controller: _policyIdController,
//                   label: 'Policy ID',
//                   hint: 'Enter policy ID',
//                   prefixIcon: Icons.badge_outlined,
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Save Button
//                 CustomButton(
//                   text: 'Save Changes',
//                   onPressed: _handleSave,
//                   isLoading: _isLoading,
//                 ),
//                 const SizedBox(height: 16),
//
//                 CustomButton(
//                   text: 'Cancel',
//                   onPressed: () => Navigator.pop(context),
//                   isOutlined: true,
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// // import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// // import 'package:arogyaraksha_ai/presentation/widgets/custom_text_field.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class EditProfileScreen extends StatefulWidget {
// //   const EditProfileScreen({super.key});
// //
// //   @override
// //   State<EditProfileScreen> createState() => _EditProfileScreenState();
// // }
// //
// // class _EditProfileScreenState extends State<EditProfileScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   final _nameController = TextEditingController();
// //   final _ageController = TextEditingController();
// //   final _addressController = TextEditingController();
// //   final _phoneController = TextEditingController();
// //   final _allergiesController = TextEditingController();
// //   final _insuranceProviderController = TextEditingController();
// //   final _policyIdController = TextEditingController();
// //
// //   String? _selectedBloodGroup;
// //   final List<String> _bloodGroups = [
// //     'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
// //   ];
// //
// //   bool _isLoading = false;
// //   bool _isLoadingData = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadUserData();
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     try {
// //       final userId = _auth.currentUser?.uid;
// //       if (userId == null) return;
// //
// //       final doc = await _firestore.collection('users').doc(userId).get();
// //
// //       if (doc.exists) {
// //         final data = doc.data()!;
// //         setState(() {
// //           _nameController.text = data['name'] ?? '';
// //           _ageController.text = data['age']?.toString() ?? '';
// //           _addressController.text = data['address'] ?? '';
// //           _phoneController.text = data['phone'] ?? '';
// //           _selectedBloodGroup = data['bloodGroup'];
// //           _allergiesController.text = data['medicalHistory']?['allergies'] ?? '';
// //           _insuranceProviderController.text = data['insurance']?['provider'] ?? '';
// //           _policyIdController.text = data['insurance']?['policyId'] ?? '';
// //           _isLoadingData = false;
// //         });
// //       }
// //     } catch (e) {
// //       print('Error loading user data: $e');
// //       setState(() => _isLoadingData = false);
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _ageController.dispose();
// //     _addressController.dispose();
// //     _phoneController.dispose();
// //     _allergiesController.dispose();
// //     _insuranceProviderController.dispose();
// //     _policyIdController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _handleSave() async {
// //     if (_formKey.currentState!.validate()) {
// //       setState(() => _isLoading = true);
// //
// //       try {
// //         final userId = _auth.currentUser?.uid;
// //         if (userId == null) return;
// //
// //         await _firestore.collection('users').doc(userId).update({
// //           'name': _nameController.text.trim(),
// //           'age': int.tryParse(_ageController.text.trim()),
// //           'bloodGroup': _selectedBloodGroup,
// //           'address': _addressController.text.trim(),
// //           'phone': _phoneController.text.trim(),
// //           'medicalHistory.allergies': _allergiesController.text.trim(),
// //           'insurance.provider': _insuranceProviderController.text.trim(),
// //           'insurance.policyId': _policyIdController.text.trim(),
// //           'updatedAt': FieldValue.serverTimestamp(),
// //         });
// //
// //         // Update display name in Auth
// //         await _auth.currentUser?.updateDisplayName(_nameController.text.trim());
// //
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('Profile updated successfully'),
// //               backgroundColor: AppColors.successGreen,
// //             ),
// //           );
// //           Navigator.pop(context, true); // Return true to indicate success
// //         }
// //       } catch (e) {
// //         print('Error updating profile: $e');
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('Failed to update profile'),
// //               backgroundColor: AppColors.alertRed,
// //             ),
// //           );
// //         }
// //       } finally {
// //         if (mounted) {
// //           setState(() => _isLoading = false);
// //         }
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoadingData) {
// //       return Scaffold(
// //         backgroundColor: AppColors.backgroundLight,
// //         appBar: AppBar(title: const Text('Edit Profile')),
// //         body: const Center(
// //           child: CircularProgressIndicator(color: AppColors.primaryTeal),
// //         ),
// //       );
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundLight,
// //       appBar: AppBar(
// //         title: const Text('Edit Profile'),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24.0),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Profile Picture Section
// //                 Center(
// //                   child: Stack(
// //                     children: [
// //                       Container(
// //                         width: 120,
// //                         height: 120,
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(
// //                             color: AppColors.primaryTeal,
// //                             width: 3,
// //                           ),
// //                           image: const DecorationImage(
// //                             image: NetworkImage('https://via.placeholder.com/150'),
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //                       ),
// //                       Positioned(
// //                         bottom: 0,
// //                         right: 0,
// //                         child: GestureDetector(
// //                           onTap: () {
// //                             // TODO: Handle image picker
// //                           },
// //                           child: Container(
// //                             width: 40,
// //                             height: 40,
// //                             decoration: BoxDecoration(
// //                               gradient: AppColors.primaryGradient,
// //                               shape: BoxShape.circle,
// //                               border: Border.all(
// //                                 color: AppColors.white,
// //                                 width: 3,
// //                               ),
// //                             ),
// //                             child: const Icon(
// //                               Icons.camera_alt_outlined,
// //                               color: AppColors.white,
// //                               size: 20,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 32),
// //
// //                 // Personal Details
// //                 Text(
// //                   'Personal Details',
// //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomTextField(
// //                   controller: _nameController,
// //                   label: 'Full Name',
// //                   hint: 'Enter your name',
// //                   prefixIcon: Icons.person_outlined,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter your name';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: CustomTextField(
// //                         controller: _ageController,
// //                         label: 'Age',
// //                         hint: 'Enter age',
// //                         prefixIcon: Icons.cake_outlined,
// //                         keyboardType: TextInputType.number,
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Required';
// //                           }
// //                           return null;
// //                         },
// //                       ),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Blood Group',
// //                             style: Theme.of(context).textTheme.titleSmall?.copyWith(
// //                               fontWeight: FontWeight.w600,
// //                               color: AppColors.textPrimary,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(horizontal: 12),
// //                             decoration: BoxDecoration(
// //                               color: AppColors.white,
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(color: AppColors.backgroundGrey),
// //                             ),
// //                             child: DropdownButtonHideUnderline(
// //                               child: DropdownButton<String>(
// //                                 value: _selectedBloodGroup,
// //                                 isExpanded: true,
// //                                 icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryTeal),
// //                                 items: _bloodGroups.map((String value) {
// //                                   return DropdownMenuItem<String>(
// //                                     value: value,
// //                                     child: Text(value),
// //                                   );
// //                                 }).toList(),
// //                                 onChanged: (String? newValue) {
// //                                   setState(() => _selectedBloodGroup = newValue);
// //                                 },
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomTextField(
// //                   controller: _addressController,
// //                   label: 'Address',
// //                   hint: 'Enter your address',
// //                   prefixIcon: Icons.location_on_outlined,
// //                   maxLines: 2,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter your address';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomTextField(
// //                   controller: _phoneController,
// //                   label: 'Contact Number',
// //                   hint: 'Enter phone number',
// //                   prefixIcon: Icons.phone_outlined,
// //                   keyboardType: TextInputType.phone,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter your phone number';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //
// //                 const SizedBox(height: 32),
// //
// //                 // Medical History
// //                 Text(
// //                   'Medical History',
// //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomTextField(
// //                   controller: _allergiesController,
// //                   label: 'Allergies',
// //                   hint: 'Enter any allergies',
// //                   prefixIcon: Icons.medical_information_outlined,
// //                   maxLines: 2,
// //                 ),
// //
// //                 const SizedBox(height: 32),
// //
// //                 // Insurance Details
// //                 Text(
// //                   'Insurance Details',
// //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomTextField(
// //                   controller: _insuranceProviderController,
// //                   label: 'Insurance Provider',
// //                   hint: 'Enter provider name',
// //                   prefixIcon: Icons.business_outlined,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomTextField(
// //                   controller: _policyIdController,
// //                   label: 'Policy ID',
// //                   hint: 'Enter policy ID',
// //                   prefixIcon: Icons.badge_outlined,
// //                 ),
// //
// //                 const SizedBox(height: 32),
// //
// //                 // Save Button
// //                 CustomButton(
// //                   text: 'Save Changes',
// //                   onPressed: _handleSave,
// //                   gradient: AppColors.primaryGradient,
// //                   isLoading: _isLoading,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 CustomButton(
// //                   text: 'Cancel',
// //                   onPressed: () => Navigator.pop(context),
// //                   isOutlined: true,
// //                   borderColor: AppColors.textLight,
// //                   textColor: AppColors.textPrimary,
// //                 ),
// //
// //                 const SizedBox(height: 24),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:arogyaraksha_ai/core/constants/app_colors.dart';
// // // import 'package:arogyaraksha_ai/presentation/widgets/custom_button.dart';
// // // import 'package:arogyaraksha_ai/presentation/widgets/custom_text_field.dart';
// // //
// // // class EditProfileScreen extends StatefulWidget {
// // //   const EditProfileScreen({super.key});
// // //
// // //   @override
// // //   State<EditProfileScreen> createState() => _EditProfileScreenState();
// // // }
// // //
// // // class _EditProfileScreenState extends State<EditProfileScreen> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _nameController = TextEditingController(text: 'Noaha');
// // //   final _ageController = TextEditingController(text: '25');
// // //   final _addressController = TextEditingController(text: 'Sydney');
// // //   final _phoneController = TextEditingController(text: '+91 XXXXXXXXXX');
// // //   final _allergiesController = TextEditingController(text: 'None');
// // //   final _insuranceProviderController = TextEditingController(text: 'Star Health');
// // //   final _policyIdController = TextEditingController(text: '#SH-2025-0041');
// // //
// // //   String? _selectedBloodGroup = 'B+';
// // //   final List<String> _bloodGroups = [
// // //     'A+',
// // //     'A-',
// // //     'B+',
// // //     'B-',
// // //     'O+',
// // //     'O-',
// // //     'AB+',
// // //     'AB-'
// // //   ];
// // //
// // //   bool _isLoading = false;
// // //
// // //   @override
// // //   void dispose() {
// // //     _nameController.dispose();
// // //     _ageController.dispose();
// // //     _addressController.dispose();
// // //     _phoneController.dispose();
// // //     _allergiesController.dispose();
// // //     _insuranceProviderController.dispose();
// // //     _policyIdController.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _handleSave() async {
// // //     if (_formKey.currentState!.validate()) {
// // //       setState(() {
// // //         _isLoading = true;
// // //       });
// // //
// // //       // Simulate API call
// // //       await Future.delayed(const Duration(seconds: 2));
// // //
// // //       if (mounted) {
// // //         setState(() {
// // //           _isLoading = false;
// // //         });
// // //
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Profile updated successfully'),
// // //             backgroundColor: AppColors.successGreen,
// // //           ),
// // //         );
// // //
// // //         Navigator.pop(context);
// // //       }
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: AppColors.backgroundLight,
// // //       appBar: AppBar(
// // //         title: const Text('Edit Profile'),
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24.0),
// // //           child: Form(
// // //             key: _formKey,
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // Profile Picture Section
// // //                 Center(
// // //                   child: Stack(
// // //                     children: [
// // //                       Container(
// // //                         width: 120,
// // //                         height: 120,
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           border: Border.all(
// // //                             color: AppColors.primaryTeal,
// // //                             width: 3,
// // //                           ),
// // //                           image: const DecorationImage(
// // //                             image: NetworkImage(
// // //                               'https://via.placeholder.com/150',
// // //                             ),
// // //                             fit: BoxFit.cover,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       Positioned(
// // //                         bottom: 0,
// // //                         right: 0,
// // //                         child: GestureDetector(
// // //                           onTap: () {
// // //                             // Handle image picker
// // //                           },
// // //                           child: Container(
// // //                             width: 40,
// // //                             height: 40,
// // //                             decoration: BoxDecoration(
// // //                               gradient: AppColors.primaryGradient,
// // //                               shape: BoxShape.circle,
// // //                               border: Border.all(
// // //                                 color: AppColors.white,
// // //                                 width: 3,
// // //                               ),
// // //                             ),
// // //                             child: const Icon(
// // //                               Icons.camera_alt_outlined,
// // //                               color: AppColors.white,
// // //                               size: 20,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 32),
// // //
// // //                 // Personal Details
// // //                 Text(
// // //                   'Personal Details',
// // //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomTextField(
// // //                   controller: _nameController,
// // //                   label: 'Full Name',
// // //                   hint: 'Enter your name',
// // //                   prefixIcon: Icons.person_outlined,
// // //                   validator: (value) {
// // //                     if (value == null || value.isEmpty) {
// // //                       return 'Please enter your name';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: CustomTextField(
// // //                         controller: _ageController,
// // //                         label: 'Age',
// // //                         hint: 'Enter age',
// // //                         prefixIcon: Icons.cake_outlined,
// // //                         keyboardType: TextInputType.number,
// // //                         validator: (value) {
// // //                           if (value == null || value.isEmpty) {
// // //                             return 'Required';
// // //                           }
// // //                           return null;
// // //                         },
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 16),
// // //                     Expanded(
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Text(
// // //                             'Blood Group',
// // //                             style: Theme.of(context)
// // //                                 .textTheme
// // //                                 .titleSmall
// // //                                 ?.copyWith(
// // //                               fontWeight: FontWeight.w600,
// // //                               color: AppColors.textPrimary,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 8),
// // //                           Container(
// // //                             padding: const EdgeInsets.symmetric(horizontal: 12),
// // //                             decoration: BoxDecoration(
// // //                               color: AppColors.white,
// // //                               borderRadius: BorderRadius.circular(12),
// // //                               border: Border.all(
// // //                                   color: AppColors.backgroundGrey),
// // //                             ),
// // //                             child: DropdownButtonHideUnderline(
// // //                               child: DropdownButton<String>(
// // //                                 value: _selectedBloodGroup,
// // //                                 isExpanded: true,
// // //                                 icon: const Icon(
// // //                                   Icons.arrow_drop_down,
// // //                                   color: AppColors.primaryTeal,
// // //                                 ),
// // //                                 items: _bloodGroups.map((String value) {
// // //                                   return DropdownMenuItem<String>(
// // //                                     value: value,
// // //                                     child: Text(value),
// // //                                   );
// // //                                 }).toList(),
// // //                                 onChanged: (String? newValue) {
// // //                                   setState(() {
// // //                                     _selectedBloodGroup = newValue;
// // //                                   });
// // //                                 },
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomTextField(
// // //                   controller: _addressController,
// // //                   label: 'Address',
// // //                   hint: 'Enter your address',
// // //                   prefixIcon: Icons.location_on_outlined,
// // //                   maxLines: 2,
// // //                   validator: (value) {
// // //                     if (value == null || value.isEmpty) {
// // //                       return 'Please enter your address';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomTextField(
// // //                   controller: _phoneController,
// // //                   label: 'Contact Number',
// // //                   hint: 'Enter phone number',
// // //                   prefixIcon: Icons.phone_outlined,
// // //                   keyboardType: TextInputType.phone,
// // //                   validator: (value) {
// // //                     if (value == null || value.isEmpty) {
// // //                       return 'Please enter your phone number';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //
// // //                 const SizedBox(height: 32),
// // //
// // //                 // Medical History
// // //                 Text(
// // //                   'Medical History',
// // //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomTextField(
// // //                   controller: _allergiesController,
// // //                   label: 'Allergies',
// // //                   hint: 'Enter any allergies',
// // //                   prefixIcon: Icons.medical_information_outlined,
// // //                   maxLines: 2,
// // //                 ),
// // //
// // //                 const SizedBox(height: 32),
// // //
// // //                 // Insurance Details
// // //                 Text(
// // //                   'Insurance Details',
// // //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomTextField(
// // //                   controller: _insuranceProviderController,
// // //                   label: 'Insurance Provider',
// // //                   hint: 'Enter provider name',
// // //                   prefixIcon: Icons.business_outlined,
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomTextField(
// // //                   controller: _policyIdController,
// // //                   label: 'Policy ID',
// // //                   hint: 'Enter policy ID',
// // //                   prefixIcon: Icons.badge_outlined,
// // //                 ),
// // //
// // //                 const SizedBox(height: 32),
// // //
// // //                 // Save Button
// // //                 CustomButton(
// // //                   text: 'Save Changes',
// // //                   onPressed: _handleSave,
// // //                   gradient: AppColors.primaryGradient,
// // //                   isLoading: _isLoading,
// // //                 ),
// // //
// // //                 const SizedBox(height: 16),
// // //
// // //                 CustomButton(
// // //                   text: 'Cancel',
// // //                   onPressed: () => Navigator.pop(context),
// // //                   isOutlined: true,
// // //                   borderColor: AppColors.textLight,
// // //                   textColor: AppColors.textPrimary,
// // //                 ),
// // //
// // //                 const SizedBox(height: 24),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }