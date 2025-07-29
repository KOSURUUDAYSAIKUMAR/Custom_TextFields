import 'dart:io';
import 'package:example/otp_view.dart';
import 'package:example/widgets/date_picker_demo_page.dart';
import 'package:example/widgets/pin_code_widget.dart';
import 'package:example/widgets/username_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

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
                hint: "Enter your email",
                controller: _emailController,
                focusNode: _emailNode,
                iconColor: Colors.grey,
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
                hint: 'Enter your full name',
              ),
              const SizedBox(height: 16),

              const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                leadingIcon: null,
                controller: _phoneController,
                focusNode: _phoneNode,
                style: PhoneFieldStyle.dropdown,
              ),
              const SizedBox(height: 15),

              const Text(
                'Fixed Country Code Style',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                leadingIcon: null,
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: PhoneFieldStyle.simple,
              ),
              const SizedBox(height: 15),

              const Text(
                'Phone number with Icons',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                leadingIcon: Icon(
                  Icons.phone_android_rounded,
                  color: Colors.grey,
                ),
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: PhoneFieldStyle.withIcons,
              ),
              const SizedBox(height: 15),

              const Text(
                'Phone number with Normal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FlexiblePhoneField(
                leadingIcon: null,
                controller: TextEditingController(),
                focusNode: FocusNode(),
                style: PhoneFieldStyle.integrated,
              ),
              const SizedBox(height: 15),

              const Text(
                'User Name TextField',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              UsernameText(
                usernameController: _usernameController,
                usernameNode: _usernameNode,
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
                validationPattern: RegExp(r'^[a-zA-Z0-9@$!%*?&]{8,20}$'),
                minPasswordLength: 8,
                maxPasswordLength: 20,
              ),
              const SizedBox(height: 24),
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
                validationPattern: RegExp(r'^[a-zA-Z0-9@$!%*?&]{8,20}$'),
                minPasswordLength: 8,
                maxPasswordLength: 20,
              ),
              const SizedBox(height: 24),
              const Text('Pin code'),
              CustomPinCodeWidget(),
              // SimplePinCodeWidget(),
              // PinCodeTextfield(
              //   controller: _pincodeController,
              //   hint: 'Enter 6-digit PIN',
              //   invalidMessage: 'Please enter a valid Indian PIN code',
              //   requiredMessage: 'PIN code is required',
              //   onValidationComplete: (response) {
              //     if (response['Status'] == 'Success') {
              //       // Handle successful validation
              //     }
              //   },
              //   leadingIcon: Icon(
              //     Icons.location_on_outlined,
              //     color: Colors.grey,
              //   ),
              //   onFieldSubmitted: (p0) {
              //     print('Pin code submitted: $p0');
              //     return null;
              //   },
              // ),
              const SizedBox(height: 24.0),
              const Text(
                'Description (max 200 characters, required):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextArea(
                hint: 'Enter a detailed description...',
                maxLength: 200,
                textInputAction: TextInputAction.next,
              ),
              // CameraWithLocationWidget(
              //   showLocationWatermark: true,
              //   onPictureTaken: (imagePath) {
              //     print("Image path ----- $imagePath");
              //   },
              // ),
              // CameraLocationPicker(
              //   enableCamera: true,
              //   enableLocation: true,
              //   enableWatermark: true,
              //   y: 200,
              //   //   waterMarkText:
              //   //     'MyApp © ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())}',
              //   onResult: (result) {
              //     // handle the captured File, coords, address
              //     print('File: ${result.imageFile.path}');
              //     print('Lat: ${result.latitude}');
              //     print('Lng: ${result.longitude}');
              //     print('Address: ${result.address}');
              //   },
              // ),
              ElevatedButton(
                onPressed: () => _openCamera(context),
                child: const Text('Open Camera Picker'),
              ),

              const SizedBox(height: 24.0),
              const Text(
                'Date Picker Demo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DatePickerDemoPage(),
                    ),
                  );
                },
                child: const Text('Open Date Picker Demo'),
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

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              // appBar: AppBar(title: const Text('Capture Image')),
              body: CameraLocationPicker(
                enableLocation: true,
                enableCamera: true,
                enableWatermark: true,
                cameraMode: CameraMode.front,
                callback: (image, lat, lng, address) {
                  print("Received data:");
                  print("Image: ${image?.path}");
                  print("Lat: $lat");
                  print("Lng: $lng");
                  print("Address: $address");

                  Navigator.pop(context);
                  _showResult(context, image, lat, lng, address);
                },
              ),
            ),
      ),
    );
  }

  void _showResult(
    BuildContext context,
    File? image,
    double? lat,
    double? lng,
    String? address,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Capture Result'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image != null) ...[
                    Image.file(image, fit: BoxFit.contain),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            _downloadImage(image);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () async {
                            _shareImage(image);
                          },
                        ),
                      ],
                    ),
                  ],
                  if (image == null) ...[
                    const SizedBox(height: 20),
                    Text('Latitude: ${lat ?? 'N/A'}'),
                    Text('Longitude: ${lng ?? 'N/A'}'),
                    Text('Address: ${address ?? 'N/A'}'),
                  ],

                  // ConstrainedBox(
                  //   constraints: const BoxConstraints(
                  //     maxHeight: 300,
                  //     maxWidth: 300,
                  //   ),
                  //   child: Image.file(image, fit: BoxFit.contain),
                  // ),
                  // const SizedBox(height: 20),
                  // Text('Latitude: ${lat ?? 'N/A'}'),
                  // Text('Longitude: ${lng ?? 'N/A'}'),
                  // Text('Address: ${address ?? 'N/A'}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _downloadImage(File image) async {
    try {
      final newPath = await FileUtils.saveToDownloads(image);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image saved to: $newPath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _shareImage(File image) async {
    try {
      await FileUtils.shareImage(image);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image shared successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sharing failed: ${e.toString()}')),
      );
    }
  }
}
