import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

class AdvancedOTPDemoScreen extends StatefulWidget {
  const AdvancedOTPDemoScreen({super.key});

  @override
  State<AdvancedOTPDemoScreen> createState() => _AdvancedOTPDemoScreenState();
}

class _AdvancedOTPDemoScreenState extends State<AdvancedOTPDemoScreen> {
  final GlobalKey<AdvancedOTPFieldState> _otpFieldKey =
      GlobalKey<AdvancedOTPFieldState>();
  String _enteredOTP = '';
  String? _errorMessage;
  bool _isVerifying = false;
  String _correctOTP = '';
  int otpLength = 6;

  final OTPAnimationType _animationType = OTPAnimationType.scale;
  final OTPInputType _inputType = OTPInputType.numeric;
  final String _placeholderText = '*';
  final bool _obscureText = false;
  final bool _enableActiveFill = true;

  @override
  void initState() {
    super.initState();
    if (otpLength == 4) {
      _correctOTP = "1234";
    } else if (otpLength == 6) {
      _correctOTP = "123456";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          _buildOTPFieldSection(),
          const SizedBox(height: 32),
          _buildVerifyButton(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOTPFieldSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (24 * 2);
    var fieldWidth = max(40.0, (availableWidth - (24 * 3)) / otpLength);
    if (otpLength == 6) {
      fieldWidth -= 5;
    }
    return Column(
      children: [
        AdvancedOTPField(
          key: _otpFieldKey,
          length: otpLength,
          inputType: _inputType,
          animationType: _animationType,
          obscureText: _obscureText,
          enableActiveFill: _enableActiveFill,
          autoFocus: false,
          fieldStyle: OTPFieldStyle(
            // width: otpLength == 6 ? 35 : fieldWidth,
            // height: otpLength == 6 ? 35 : fieldWidth,
            width: fieldWidth,
            height: fieldWidth,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            placeholderText: _placeholderText,
            textStyle: TextStyle(
              fontSize: otpLength == 6 ? 12 : 24,
              fontWeight: FontWeight.bold,
            ),
            placeholderStyle: TextStyle(
              fontSize: otpLength == 6 ? 10 : 20,
              fontWeight: FontWeight.w300,
              color: Colors.grey[400],
            ),
            showCursor: true,
            cursorColor: Colors.blue,
            cursorWidth: 2,
            cursorHeight: 32,
            showPlaceholderOnlyForEmptyBox: true,
          ),
          fieldDecoration: OTPFieldDecoration(
            borderRadius: BorderRadius.circular(12),
            borderWidth: 1.5,
            activeColor: Colors.grey[300],
            inactiveColor: Colors.grey[300],
            selectedColor: Colors.blue,
            errorColor: Colors.red[400],
            backgroundColor: Colors.grey[50],
            boxShadow: BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ),
          errorText: _errorMessage,
          onChanged: (value) {
            setState(() {
              _enteredOTP = value;
              _errorMessage = null;
              // if (_isFirstInput && value.isNotEmpty) {
              //   _isFirstInput = false;
              // }
              // _activeIndex = value.length;
            });
          },
          onCompleted: (value) {
            _verifyOTP(value);
          },
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            _enteredOTP.length == otpLength &&
                    !_isVerifying // Enable when 4 digits entered
                ? () => _verifyOTP(_enteredOTP)
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        child:
            _isVerifying
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _otpFieldKey.currentState?.clear();
              setState(() {
                _enteredOTP = '';
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showSnackBar('New OTP sent successfully!', Colors.green);
              _otpFieldKey.currentState?.clear();
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Resend'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _verifyOTP(String otp) {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVerifying = false;
      });

      if (otp == _correctOTP) {
        _showSnackBar('OTP verified successfully!', Colors.green);
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
        _otpFieldKey.currentState?.clear(); // Clear the field on invalid OTP
        _otpFieldKey.currentState?.animateError(); // Show error animation
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
