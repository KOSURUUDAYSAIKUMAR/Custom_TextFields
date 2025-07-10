import 'package:example/otp_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:intl/intl.dart';

class FormExample extends StatefulWidget {
  const FormExample({super.key});

  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pincodeController = TextEditingController();

  final FocusNode _emailNode = FocusNode();
  final FocusNode _fullnameNode = FocusNode();
  final FocusNode _usernameNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  final FocusNode _pinCodeNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _phoneController.dispose();
    _emailNode.dispose();
    _fullnameNode.dispose();
    _usernameNode.dispose();
    _phoneNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    _pinCodeNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
      print('Email: ${_emailController.text}');
      print('Username: ${_usernameController.text}');
      print('Full Name: ${_fullnameController.text}');
      print('Phone: ${_phoneController.text}');
    } else {
      // Show error message when form is invalid on submit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Custom Fields Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              const Text(
                'Email Field with Validation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              EmailTextField(
                controller: _emailController,
                focusNode: _emailNode,
                iconColor: Theme.of(context).primaryColor,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                invalidEmailMessage: 'Please enter a valid email address',
                requiredEmailMessage: 'Email is required',
              ),
              const SizedBox(height: 16),

              const Text(
                'Full Name with Validation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FullNameTextField(
                focusNode: _fullnameNode,
                controller: _fullnameController,
                iconColor: Theme.of(context).primaryColor,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                invalidNameMessage: 'Please enter a valid name',
                requiredNameMessage: 'Full name is required',
              ),
              const SizedBox(height: 16),

              const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                controller: _phoneController,
                focusNode: _phoneNode,
                style: PhoneFieldStyle.dropdown,
                isShowError: true,
              ),
              const SizedBox(height: 15),

              const Text(
                'Fixed Country Code Style',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: PhoneFieldStyle.simple,
                isShowError: true,
              ),
              const SizedBox(height: 15),

              const Text(
                'Phone number with Icons',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: PhoneFieldStyle.withIcons,
                isShowError: true,
              ),
              const SizedBox(height: 15),

              const Text(
                'Phone number with Normal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: PhoneFieldStyle.integrated,
                isShowError: true,
              ),
              const SizedBox(height: 15),

              const Text(
                'User Name TextField',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              UsernameTextfield(
                controller: _usernameController,
                focusNode: _usernameNode,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                patternErrorMessage:
                    'Username must be 3-20 characters and can only contain letters, numbers, and underscore',
              ),
              const SizedBox(height: 24),

              const Text(
                'OTP Field',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: AdvancedOTPDemoScreen()),
              const SizedBox(height: 24),
              const Text(
                'Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              PasswordTextfield(
                controller: _passwordController,
                focusNode: _passwordNode,
                hint: "Enter password",
              ),
              const Text(
                'Confirm Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              PasswordTextfield(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordNode,
                hint: "Enter confirm password",
                compareWithController: _passwordController,
                passwordMismatchMessage:
                    'Confirm password does not match with the password.',
              ),
              const SizedBox(height: 24),
              const Text('Pin code'),
              PinCodeTextfield(
                controller: _pincodeController,
                hint: 'Enter 6-digit PIN',
                invalidMessage: 'Please enter a valid Indian PIN code',
                requiredMessage: 'PIN code is required',
                onValidationComplete: (response) {
                  if (response['Status'] == 'Success') {
                    // Handle successful validation
                  }
                },
                leadingIcon: Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Description (max 200 characters, required):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextArea(
                hint: 'Enter a detailed description...',
                maxLength: 200,
                onChanged: (text) {
                  setState(() {
                    _description = text;
                  });
                },
                textInputAction: TextInputAction.next,
              ),
              // CameraWithLocationWidget(
              //   showLocationWatermark: true,
              //   onPictureTaken: (imagePath) {
              //     print("Image path ----- $imagePath");
              //   },
              // ),
              CameraLocationPicker(
                enableCamera: true,
                enableLocation: true,
                enableWatermark: true,
                y: 200,
                //   waterMarkText:
                //     'MyApp © ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())}',
                onResult: (result) {
                  // handle the captured File, coords, address
                  print('File: ${result.imageFile.path}');
                  print('Lat: ${result.latitude}');
                  print('Lng: ${result.longitude}');
                  print('Address: ${result.address}');
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
