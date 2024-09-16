import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dietController = TextEditingController();
  final TextEditingController _hipCircumferenceController = TextEditingController();
  final TextEditingController _waistCircumferenceController = TextEditingController();

  String? _selectedGender;
  XFile? _profileImage;

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _profileImage = image;
    });
  }

  // Form validation
  String? _validateInput(String? value, String field) {
    if (value == null || value.isEmpty) {
      return '$field is required';
    }
    if (field == 'Height (cm)' || field == 'Weight (kg)') {
      if (double.tryParse(value) == null) {
        return 'Enter a valid number';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile picture
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: _selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),

              // Height input
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateInput(value, 'Height (cm)'),
              ),

              // Weight input
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateInput(value, 'Weight (kg)'),
              ),

              // Dietary preferences
              TextFormField(
                controller: _dietController,
                decoration: InputDecoration(labelText: 'Dietary Preferences'),
                validator: (value) => _validateInput(value, 'Dietary Preferences'),
              ),

              TextFormField(
                controller: _hipCircumferenceController,
                decoration: InputDecoration(labelText: 'Hip Circumference (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your hip circumference';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _waistCircumferenceController,
                decoration: InputDecoration(labelText: 'Waist Circumference (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your waist circumference';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),



              SizedBox(height: 20),

              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save user data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile saved successfully!')),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _dietController.dispose();
    _waistCircumferenceController.dispose();
    _hipCircumferenceController.dispose();
    super.dispose();
  }
}
