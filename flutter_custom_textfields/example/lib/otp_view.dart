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
  final String _correctOTP = '1234';
  bool _isFirstInput = true;
  int _activeIndex = 0;

  // Configuration options
  OTPAnimationType _animationType = OTPAnimationType.scale;
  OTPInputType _inputType = OTPInputType.numeric;
  String _placeholderText = '*';
  bool _obscureText = false;
  bool _enableActiveFill = true;

  String _getPlaceholderForIndex(int index) {
    return index == _activeIndex ? '' : _placeholderText;
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
          // const SizedBox(height: 24),
          // _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOTPFieldSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (24 * 2);
    final fieldWidth = (availableWidth - (24 * 3)) / 4;

    return Column(
      children: [
        AdvancedOTPField(
          key: _otpFieldKey,
          length: 4,
          inputType: _inputType,
          animationType: _animationType,
          obscureText: _obscureText,
          enableActiveFill: _enableActiveFill,
          autoFocus: false,
          fieldStyle: OTPFieldStyle(
            width: fieldWidth,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            placeholderText: '*',
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            placeholderStyle: TextStyle(
              fontSize: 20,
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
            selectedColor: _isFirstInput ? Colors.grey[300] : Colors.blue,
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
              if (_isFirstInput && value.isNotEmpty) {
                _isFirstInput = false;
              }
              // Update active index based on input length
              _activeIndex = value.length;
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
            _enteredOTP.length == 4 &&
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

  Widget _buildFeaturesDemo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo Features',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('Auto-fill Support', Icons.auto_fix_high),
              _buildFeatureChip('Paste Support', Icons.content_paste),
              _buildFeatureChip('Custom Animations', Icons.animation),
              _buildFeatureChip('Error Handling', Icons.error_outline),
              _buildFeatureChip('Customizable UI', Icons.palette),
              _buildFeatureChip('Accessibility', Icons.accessibility),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withOpacity(0.3),
      side: BorderSide.none,
    );
  }

  void _showConfigDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Configuration'),
            content: StatefulBuilder(
              builder:
                  (context, setDialogState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animation Type
                      const Text(
                        'Animation Type:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<OTPAnimationType>(
                        value: _animationType,
                        isExpanded: true,
                        items:
                            OTPAnimationType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _animationType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Type
                      const Text(
                        'Input Type:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<OTPInputType>(
                        value: _inputType,
                        isExpanded: true,
                        items:
                            OTPInputType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _inputType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Placeholder Text
                      const Text(
                        'Placeholder:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _placeholderText,
                        decoration: const InputDecoration(
                          hintText: 'Enter placeholder character',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLength: 1,
                        onChanged: (value) {
                          setDialogState(() {
                            _placeholderText = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Toggle Options
                      SwitchListTile(
                        title: const Text('Obscure Text'),
                        value: _obscureText,
                        onChanged: (value) {
                          setDialogState(() {
                            _obscureText = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Active Fill'),
                        value: _enableActiveFill,
                        onChanged: (value) {
                          setDialogState(() {
                            _enableActiveFill = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Apply changes
                  });
                  Navigator.pop(context);
                  _otpFieldKey.currentState?.clear();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
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
