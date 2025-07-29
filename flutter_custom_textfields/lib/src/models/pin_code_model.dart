import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PinCodeModel {
  final String userEnteredPin;
  late final Dio _dio;
  late final Connectivity _connectivity;
  final CustomTextFieldsErrorMessages? _customErrorMessages;

  PinCodeModel(
    this.userEnteredPin, {
    Dio? dio,
    Connectivity? connectivity,
    CustomTextFieldsErrorMessages? customErrorMessages,
  }) : _dio = dio ?? Dio(),
       _connectivity = connectivity ?? Connectivity(),
       _customErrorMessages = customErrorMessages {
    _configureDio();
  }
  @override
  String toString() {
    return 'PinCodeModel(userEnteredPin: $userEnteredPin, '
        'dio: ${_dio.runtimeType}, '
        'connectivity: ${_connectivity.runtimeType}, '
        'customErrorMessages: $_customErrorMessages)';
  }

  void _configureDio() {
    try {
      _dio.options.baseUrl = 'https://api.postalpincode.in/';
      _dio.options.connectTimeout = const Duration(seconds: 5);
      _dio.options.sendTimeout = const Duration(seconds: 5);
      _dio.options.receiveTimeout = const Duration(seconds: 60);

      // Add a simple log interceptor if not already present
      if (!_dio.interceptors.any((i) => i is LogInterceptor)) {
        _dio.interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true),
        );
      }
    } catch (e, stack) {
      print("Error configuring Dio: $e");
      print(stack);
      rethrow;
    }
  }

  // Method that performs the validation logic and API call
  Future<Map<String, dynamic>> validatePinCode() async {
    // 1. Internet Connectivity Check
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return {
          'Status': 'Error',
          'Message':
              _customErrorMessages?.noInternetConnection ??
              'No internet connection',
          'PostOffice': null,
          'UserEnteredPin': userEnteredPin,
        };
      }

      // Check for Google connectivity as a secondary check
      try {
        final googleResponse = await _dio.get(
          'https://www.google.com',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 60),
          ),
        );
        if (googleResponse.statusCode != 200) {
          return {
            'Status': 'Error',
            'Message':
                _customErrorMessages?.noInternetConnection ??
                'No internet connection',
            'PostOffice': null,
            'UserEnteredPin': userEnteredPin,
          };
        }
        ;
      } on DioException catch (e) {
        // Treat DioExceptions during Google check as no internet
        print('Google connectivity check DioException: $e');
        return {
          'Status': 'Error',
          'Message':
              _customErrorMessages?.noInternetConnection ??
              'No internet connection',
          'PostOffice': null,
          'UserEnteredPin': userEnteredPin,
        };
      } catch (e) {
        print('Google connectivity check General Exception: $e');
        return {
          'Status': 'Error',
          'Message':
              _customErrorMessages?.noInternetConnection ??
              'No internet connection',
          'PostOffice': null,
          'UserEnteredPin': userEnteredPin,
        };
      }
    } catch (e) {
      return {
        'Status': 'Error',
        'Message':
            _customErrorMessages?.connectivityCheckFailed ??
            'Connectivity check failed',
        'PostOffice': null,
        'UserEnteredPin': userEnteredPin,
      };
    }

    // 2. Basic PIN format validation
    if (userEnteredPin.isEmpty) {
      return {
        'Status': 'Error',
        'Message':
            _customErrorMessages?.emptyPincode ?? 'PIN code cannot be empty',
        'PostOffice': null,
        'UserEnteredPin': userEnteredPin,
      };
    }
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(userEnteredPin)) {
      return {
        'Status': 'Error',
        'Message':
            _customErrorMessages?.invalidPincodeFormat ??
            'Invalid PIN code format',
        'PostOffice': null,
        'UserEnteredPin': userEnteredPin,
      };
    }

    // 3. API Call
    try {
      final response = await _dio.get('pincode/$userEnteredPin');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          final firstResult = data[0];
          if (firstResult is Map && firstResult['Status'] == 'Success') {
            return {
              'Status': 'Success',
              'Message': 'PIN code data retrieved successfully',
              'PostOffice': firstResult['PostOffice'],
              'UserEnteredPin': userEnteredPin,
            };
          } else if (firstResult is Map && firstResult['Status'] == 'Error') {
            return {
              'Status': 'Error',
              'Message':
                  _customErrorMessages?.invalidPincodeAPI ??
                  firstResult['Message'] ??
                  'Invalid PIN code (API)',
              'PostOffice': null,
              'UserEnteredPin': userEnteredPin,
            };
          }
        }
        // Handle empty API response or unexpected structure
        return {
          'Status': 'Error',
          'Message':
              _customErrorMessages?.emptyAPIResponse ??
              'Empty or unexpected API response',
          'PostOffice': null,
          'UserEnteredPin': userEnteredPin,
        };
      } else {
        // Handle non-200 status codes from API
        return {
          'Status': 'Error',
          'Message':
              _customErrorMessages?.badAPIResponse ??
              'Failed to retrieve PIN code data: Status ${response.statusCode}',
          'PostOffice': null,
          'UserEnteredPin': userEnteredPin,
        };
      }
    } on DioException catch (e) {
      String errorMessage =
          _customErrorMessages?.unknownError ?? 'An unknown error occurred';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            _customErrorMessages?.connectionTimeout ?? 'Connection timed out';
      } else if (e.type == DioExceptionType.sendTimeout) {
        errorMessage = _customErrorMessages?.sendTimeout ?? 'Send timed out';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            _customErrorMessages?.receiveTimeout ?? 'Receive timed out';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage =
            _customErrorMessages?.badAPIResponse ?? 'Bad response from server';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            _customErrorMessages?.connectionError ?? 'Connection error';
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMessage =
            _customErrorMessages?.sslCertificateError ??
            'SSL certificate error';
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException) {
          // Example for handling specific unknown errors
          errorMessage =
              _customErrorMessages?.connectionError ?? 'Network unreachable';
        } else {
          errorMessage =
              _customErrorMessages?.unknownError ?? 'Unknown network error';
        }
      }
      return {
        'Status': 'Error',
        'Message': errorMessage,
        'PostOffice': null,
        'UserEnteredPin': userEnteredPin,
      };
    } catch (e) {
      return {
        'Status': 'Error',
        'Message':
            _customErrorMessages?.generalError ??
            'A general error occurred: $e',
        'PostOffice': null,
        'UserEnteredPin': userEnteredPin,
      };
    }
  }

  void dispose() {
    _dio.close();
  }
}

// Assuming this class is provided by flutter_custom_textfields
class CustomTextFieldsErrorMessages {
  final String? noInternetConnection;
  final String? connectivityCheckFailed;
  final String? emptyPincode;
  final String? invalidPincodeFormat;
  final String? invalidPincodeAPI;
  final String? emptyAPIResponse;
  final String? badAPIResponse;
  final String? connectionTimeout;
  final String? sendTimeout;
  final String? receiveTimeout;
  final String? connectionError;
  final String? sslCertificateError;
  final String? unknownError;
  final String? generalError;

  const CustomTextFieldsErrorMessages({
    this.noInternetConnection,
    this.connectivityCheckFailed,
    this.emptyPincode,
    this.invalidPincodeFormat,
    this.invalidPincodeAPI,
    this.emptyAPIResponse,
    this.badAPIResponse,
    this.connectionTimeout,
    this.sendTimeout,
    this.receiveTimeout,
    this.connectionError,
    this.sslCertificateError,
    this.unknownError,
    this.generalError,
  });
}
