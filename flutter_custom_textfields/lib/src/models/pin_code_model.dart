// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_custom_textfields/src/validator/pin_code_validator.dart';

// class PinCodeModel {
//   final String pincode;
//   final String invalidMessage;
//   final String validMessage;
//   PinCodeModel(this.pincode, this.invalidMessage, this.validMessage);

//   Future<Map<String, dynamic>> validatePinCode() async {
//     // final validationError = PinCodeValidator.validate(
//     //   pincode,
//     //   invalidMessage,
//     //   validMessage,
//     // );
//     // if (validationError != null) {
//     //   return {
//     //     'Status': 'Error',
//     //     'Message': validationError,
//     //     'PostOffice': null,
//     //   };
//     // }

//     final hasConnection = await _checkInternetConnection();
//     if (!hasConnection) {
//       return {
//         'Status': 'Error',
//         'Message': 'No internet connection',
//         'PostOffice': null,
//         'UserEnteredPin': pincode,
//       };
//     }
//     try {
//       final result = await _callPinCodeAPI();
//       return result;
//     } catch (e) {
//       return {
//         'Status': 'Error',
//         'Message': 'Failed to validate PIN code: ${e.toString()}',
//         'PostOffice': null,
//         'UserEnteredPin': pincode,
//       };
//     }
//   }

//   Future<bool> _checkInternetConnection() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return true;
//       }
//     } on SocketException catch (_) {
//       return false;
//     }
//     return false;
//   }

//   Future<Map<String, dynamic>> _callPinCodeAPI() async {
//     final url = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
//     final httpClient = HttpClient();
//     try {
//       final request = await httpClient.getUrl(url);
//       final response = await request.close();
//       if (response.statusCode == HttpStatus.ok) {
//         final responseBody = await response.transform(utf8.decoder).join();
//         final jsonResponse = json.decode(responseBody);
//         if (jsonResponse is List && jsonResponse.isNotEmpty) {
//           return jsonResponse[0] as Map<String, dynamic>;
//         }
//       }
//       return {
//         'Status': 'Error',
//         'Message': 'Invalid API response',
//         'PostOffice': null,
//       };
//     } finally {
//       httpClient.close();
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter_custom_textfields/src/validator/pin_code_validator.dart';

class PinCodeModel {
  final String pincode;
  final String? invalidMessage;
  final String? requiredMessage;

  PinCodeModel(this.pincode, {this.invalidMessage, this.requiredMessage});

  Future<Map<String, dynamic>> validatePinCode() async {
    final validationError = PinCodeValidator.validate(
      pincode,
      invalidPinCodeMessage: invalidMessage,
      requiredPinCodeMessage: requiredMessage,
    );

    if (validationError != null) {
      return {
        'Status': 'Error',
        'Message': validationError,
        'PostOffice': null,
        'UserEnteredPin': pincode,
      };
    }

    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      return {
        'Status': 'Error',
        'Message': 'No internet connection',
        'PostOffice': null,
        'UserEnteredPin': pincode,
      };
    }

    try {
      final result = await _callPinCodeAPI();

      if (result is List && result.isNotEmpty) {
        return result[0] as Map<String, dynamic>;
      } else if (result is Map<String, dynamic>) {
        return result;
      }
      return {
        'Status': 'Error',
        'Message': 'Unexpected API response format',
        'PostOffice': null,
        'UserEnteredPin': pincode,
      };
    } catch (e) {
      return {
        'Status': 'Error',
        'Message':
            'Failed to validate PIN code due to API error: ${e.toString()}',
        'PostOffice': null,
        'UserEnteredPin': pincode,
      };
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<dynamic> _callPinCodeAPI() async {
    final url = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
    final httpClient = HttpClient();
    // httpClient.connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonResponse = json.decode(responseBody);
        return jsonResponse;
      } else {
        return {
          'Status': 'Error',
          'Message': 'API call failed with status: ${response.statusCode}',
          'PostOffice': null,
        };
      }
    } on SocketException {
      throw 'No internet connection or host unreachable.';
    } on HandshakeException {
      throw 'SSL handshake error. Check certificate validity.';
    } on FormatException {
      throw 'Invalid JSON response from API.';
    } catch (e) {
      throw 'An unexpected network error occurred: ${e.toString()}';
    } finally {
      httpClient.close();
    }
  }
}
