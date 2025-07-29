import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

class CustomPinCodeWidget extends StatefulWidget {
  const CustomPinCodeWidget({super.key});

  @override
  State<CustomPinCodeWidget> createState() => _CustomPinCodeWidgetState();
}

class _CustomPinCodeWidgetState extends State<CustomPinCodeWidget> {
  final TextEditingController _pincodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ValidationStatus _validationStatus = ValidationStatus.none;
  bool _isLoading = false;
  Map<String, dynamic>? _apiResponse;
  String? _errorMessage;

  @override
  void dispose() {
    _pincodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onCheckButtonPressed() async {
    if (_pincodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'PIN code is required';
        _apiResponse = null;
      });
      return;
    }

    if (_pincodeController.text.length != 6) {
      setState(() {
        _errorMessage = 'PIN code must be 6 digits';
        _apiResponse = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _validationStatus = ValidationStatus.loading;
      _errorMessage = null;
      _apiResponse = null;
    });

    try {
      // Create the PinCodeModel directly to call the API
      // final model = PinCodeModel(
      //   _pincodeController.text.trim(),
      //   invalidMessage: 'Please enter a valid Indian PIN code',
      //   requiredMessage: 'PIN code is required',
      // );

      final model = PinCodeModel(_pincodeController.text.trim());

      final response = await model.validatePinCode();

      setState(() {
        _isLoading = false;
        _apiResponse = response;
        if (response['Status'] != 'Success') {
          _errorMessage = response['Message'] ?? 'Invalid PIN code';
          _validationStatus = ValidationStatus.error;
        } else {
          _validationStatus = ValidationStatus.success;
          _errorMessage = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to validate PIN code: ${e.toString()}';
        _apiResponse = null;
        _validationStatus = ValidationStatus.error;
      });
    }
  }

  Widget _buildResponseUI() {
    if (_isLoading || _validationStatus == ValidationStatus.loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Validating PIN code...',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_apiResponse != null && _apiResponse!['Status'] == 'Success') {
      final postOffice = _apiResponse!['PostOffice'] as List?;
      if (postOffice != null && postOffice.isNotEmpty) {
        final office = postOffice[0] as Map<String, dynamic>;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Valid PIN Code',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Post Office:', office['Name'] ?? 'N/A'),
              _buildInfoRow('District:', office['District'] ?? 'N/A'),
              _buildInfoRow('State:', office['State'] ?? 'N/A'),
              _buildInfoRow('Branch Type:', office['BranchType'] ?? 'N/A'),
              _buildInfoRow(
                'Delivery Status:',
                office['DeliveryStatus'] ?? 'N/A',
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: PinCodeTextfield(
                  maxLength: null,
                  controller: _pincodeController,
                  hint: 'Enter 6-digit PIN',
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _focusNode,
                  enabled: true, // Ensure field is enabled
                  readOnly: false, // Ensure field is not read-only
                  onTap: () {
                    _focusNode.requestFocus(); // Request focus on tap
                  },
                  leadingIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Enter 6-digit PIN',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
              // Check Button
              Container(
                margin: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onCheckButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Check',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                ),
              ),
            ],
          ),
        ),
        // Response UI
        _buildResponseUI(),
      ],
    );
  }
}

enum ValidationStatus { none, loading, success, error }

// import 'package:flutter/material.dart';
// import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

// class SimplePinCodeWidget extends StatefulWidget {
//   const SimplePinCodeWidget({super.key});

//   @override
//   State<SimplePinCodeWidget> createState() => _SimplePinCodeWidgetState();
// }

// class _SimplePinCodeWidgetState extends State<SimplePinCodeWidget> {
//   final TextEditingController _pincodeController = TextEditingController();
//   bool _isLoading = false;
//   Map<String, dynamic>? _apiResponse;
//   String? _errorMessage;

//   Future<void> _validatePinCode() async {
//     // Clear previous results
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _apiResponse = null;
//     });

//     try {
//       // Use the PinCodeModel from your package
//       final model = PinCodeModel(
//         _pincodeController.text.trim(),
//         invalidMessage: 'Please enter a valid Indian PIN code',
//         requiredMessage: 'PIN code is required',
//       );

//       final response = await model.validatePinCode();

//       setState(() {
//         _isLoading = false;
//         _apiResponse = response;
//         if (response['Status'] != 'Success') {
//           _errorMessage = response['Message'];
//         }
//       });

//       // Handle successful validation
//       if (response['Status'] == 'Success') {
//         // You can add your success handling here
//         print('PIN Code validated successfully!');
//         print('Post Office: ${response['PostOffice']}');
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Validation failed: ${e.toString()}';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // PIN Code Input with Check Button
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             children: [
//               // PIN Code TextField
//               Expanded(
//                 child: PinCodeTextfield(
//                   controller: _pincodeController,
//                   hint: 'Enter 6-digit PIN',
//                   invalidMessage: 'Please enter a valid Indian PIN code',
//                   requiredMessage: 'PIN code is required',
//                   validateOnComplete: false, // Disable auto-validation
//                   autovalidateMode: AutovalidateMode.disabled,
//                   leadingIcon: const Icon(
//                     Icons.location_on_outlined,
//                     color: Colors.grey,
//                   ),
//                   inputDecoration: InputDecoration(
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     hintText: 'Enter 6-digit PIN',
//                   ),
//                 ),
//               ),
//               // Check Button
//               Container(
//                 margin: const EdgeInsets.all(4),
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _validatePinCode,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade600,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                           : const Text('Check'),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Response Display
//         if (_isLoading) ...[
//           const SizedBox(height: 16),
//           const Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(width: 16),
//                   Text('Validating PIN code...'),
//                 ],
//               ),
//             ),
//           ),
//         ],

//         if (_errorMessage != null) ...[
//           const SizedBox(height: 16),
//           Card(
//             color: Colors.red.shade50,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   const Icon(Icons.error, color: Colors.red),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],

//         if (_apiResponse != null && _apiResponse!['Status'] == 'Success') ...[
//           const SizedBox(height: 16),
//           Card(
//             color: Colors.green.shade50,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green),
//                       SizedBox(width: 8),
//                       Text(
//                         'Valid PIN Code',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   if (_apiResponse!['PostOffice'] != null) ...[
//                     ...(_apiResponse!['PostOffice'] as List).map((office) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Post Office: ${office['Name'] ?? 'N/A'}'),
//                           Text('District: ${office['District'] ?? 'N/A'}'),
//                           Text('State: ${office['State'] ?? 'N/A'}'),
//                           Text('Branch Type: ${office['BranchType'] ?? 'N/A'}'),
//                         ],
//                       );
//                     }),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }
