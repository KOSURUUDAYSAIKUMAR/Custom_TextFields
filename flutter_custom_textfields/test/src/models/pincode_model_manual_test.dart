import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';

// Manual Mock Classes
class MockDio extends Mock implements Dio {
  Function? _onGet;
  Function? _onClose;
  bool _isClosed = false;

  void setGetResponse(Function response) {
    _onGet = response;
  }

  void setCloseCallback(Function callback) {
    _onClose = callback;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (_onGet != null) {
      return await _onGet!(
        path,
        data,
        queryParameters,
        options,
        cancelToken,
        onReceiveProgress,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }

  @override
  void close({bool force = false}) {
    if (_onClose != null) {
      _onClose!();
    }
    _isClosed = true;
  }

  // Fixed methods below
  @override
  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    FileAccessMode fileAccessMode = FileAccessMode.write,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<dynamic>> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    FileAccessMode fileAccessMode = FileAccessMode.write,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  // Implement other required Dio methods
  @override
  BaseOptions get options => BaseOptions();

  @override
  set options(BaseOptions options) {}

  @override
  Interceptors get interceptors => Interceptors();

  @override
  HttpClientAdapter get httpClientAdapter => throw UnimplementedError();

  @override
  set httpClientAdapter(HttpClientAdapter adapter) {}

  @override
  Transformer get transformer => throw UnimplementedError();

  @override
  set transformer(Transformer transformer) {}

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  void lock() {}

  @override
  void unlock() {}

  @override
  void clear() {}

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  // @override
  // Future<Response<dynamic>> requestUri(
  //   Uri uri, {
  //   Object? data,
  //   CancelToken? cancelToken,
  //   Options? options,
  //   ProgressCallback? onSendProgress,
  //   ProgressCallback? onReceiveProgress,
  // }) {
  //   throw UnimplementedError();
  // }

  @override
  Future<Response<T>> deleteUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patchUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> postUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> putUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }
}

class MockConnectivity extends Mock implements Connectivity {
  Function? _onCheckConnectivity;

  void setConnectivityResponse(Function response) {
    _onCheckConnectivity = response;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (_onCheckConnectivity != null) {
      return await _onCheckConnectivity!();
    }
    return [ConnectivityResult.wifi];
  }
}

void main() {
  group('PinCodeValidator Tests', () {
    group('Valid PIN codes', () {
      test('should return null for valid 6-digit PIN codes', () {
        // Test various valid PIN codes
        const validPinCodes = [
          '110001', // Delhi
          '400001', // Mumbai
          '560001', // Bangalore
          '600001', // Chennai
          '700001', // Kolkata
          '111111', // All same digits (but valid)
          '123456', // Sequential digits
          '987654', // Reverse sequential
        ];

        for (final pinCode in validPinCodes) {
          final result = PinCodeValidator.validate(pinCode);
          expect(result, isNull, reason: 'PIN code $pinCode should be valid');
        }
      });
    });

    group('Invalid PIN codes', () {
      test('should return error for null or empty PIN codes', () {
        // Test null value
        final result1 = PinCodeValidator.validate(null);
        expect(result1, equals('PIN code is required.'));

        // Test empty string
        final result2 = PinCodeValidator.validate('');
        expect(result2, equals('PIN code is required.'));

        // Test with custom required message
        final result3 = PinCodeValidator.validate(
          null,
          requiredPinCodeMessage: 'Custom required message',
        );
        expect(result3, equals('Custom required message'));
      });

      test('should return error for PIN codes with incorrect length', () {
        const invalidLengthPinCodes = [
          '1', // Too short
          '12', // Too short
          '123', // Too short
          '1234', // Too short
          '12345', // Too short
          '1234567', // Too long
          '12345678', // Too long
        ];

        for (final pinCode in invalidLengthPinCodes) {
          final result = PinCodeValidator.validate(pinCode);
          expect(
            result,
            equals('PIN code must be exactly 6 digits.'),
            reason: 'PIN code $pinCode should be invalid due to length',
          );
        }
      });

      test('should return error for PIN codes starting with 0', () {
        const invalidStartingPinCodes = [
          '012345',
          '098765',
          '000000',
          '001234',
        ];

        for (final pinCode in invalidStartingPinCodes) {
          final result = PinCodeValidator.validate(pinCode);
          expect(
            result,
            equals('Enter a valid Indian PIN code (e.g., first digit 1-9).'),
            reason: 'PIN code $pinCode should be invalid (starts with 0)',
          );
        }
      });

      test('should return error for PIN codes with non-numeric characters', () {
        const invalidCharacterPinCodes = [
          'abc123',
          '12a456',
          '123-45',
          '123 45',
          '12#456',
          'ABCDEF',
          '123.45',
        ];

        for (final pinCode in invalidCharacterPinCodes) {
          final result = PinCodeValidator.validate(pinCode);
          expect(
            result,
            equals('Enter a valid Indian PIN code (e.g., first digit 1-9).'),
            reason: 'PIN code $pinCode should be invalid (non-numeric)',
          );
        }
      });

      test('should use custom error messages when provided', () {
        const customInvalidMessage = 'Custom invalid PIN message';
        const customRequiredMessage = 'Custom required PIN message';

        // Test custom invalid message
        final result1 = PinCodeValidator.validate(
          '012345',
          invalidPinCodeMessage: customInvalidMessage,
        );
        expect(result1, equals(customInvalidMessage));

        // Test custom required message
        final result2 = PinCodeValidator.validate(
          '',
          requiredPinCodeMessage: customRequiredMessage,
        );
        expect(result2, equals(customRequiredMessage));
      });
    });
  });

  group('PinCodeModel Tests', () {
    late MockDio mockDio;
    late MockConnectivity mockConnectivity;
    late PinCodeModel pinCodeModel;

    setUp(() {
      mockDio = MockDio();
      mockConnectivity = MockConnectivity();
    });

    group('Initialization and Configuration', () {
      test(
        'should initialize with default dio and connectivity when not provided',
        () {
          final model = PinCodeModel('110001');
          expect(model.userEnteredPin, equals('110001'));
        },
      );

      test('should initialize with provided dio and connectivity', () {
        final model = PinCodeModel(
          '110001',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        expect(model.userEnteredPin, equals('110001'));
      });
    });

    group('Basic Validation', () {
      test('should return error for invalid PIN code format', () async {
        pinCodeModel = PinCodeModel(
          '012345', // Invalid: starts with 0
          dio: mockDio,
          connectivity: mockConnectivity,
        );

        final result = await pinCodeModel.validatePinCode();

        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Invalid PIN code format'));
        expect(result['PostOffice'], isNull);
        expect(result['UserEnteredPin'], equals('012345'));
      });

      test('should return error for empty PIN code', () async {
        pinCodeModel = PinCodeModel(
          '',
          dio: mockDio,
          connectivity: mockConnectivity,
        );

        final result = await pinCodeModel.validatePinCode();

        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('PIN code cannot be empty'));
        expect(result['PostOffice'], isNull);
        expect(result['UserEnteredPin'], equals(''));
      });

      test('should use custom validation messages', () async {
        pinCodeModel = PinCodeModel(
          '',
          customErrorMessages: CustomTextFieldsErrorMessages(
            invalidPincodeAPI: 'Custom Invalid message',
          ),
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        final result = await pinCodeModel.validatePinCode();

        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('PIN code cannot be empty'));
      });
    });

    group('Internet Connectivity', () {
      test('should return error when no internet connection', () async {
        pinCodeModel = PinCodeModel(
          '110001',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        mockConnectivity.setConnectivityResponse(
          () async => [ConnectivityResult.none],
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('No internet connection'));
        expect(result['PostOffice'], isNull);
        expect(result['UserEnteredPin'], equals('110001'));
      });

      test('should proceed when internet connection is available', () async {
        pinCodeModel = PinCodeModel(
          '110001',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        mockConnectivity.setConnectivityResponse(
          () async => [ConnectivityResult.wifi],
        );
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
              data: [
                {
                  'Status': 'Success',
                  'PostOffice': [
                    {
                      'Name': 'Test Post Office',
                      'Pincode': '110001',
                      'District': 'Test District',
                      'State': 'Test State',
                    },
                  ],
                },
              ],
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Success'));
        expect(result['PostOffice'], isNotNull);
        expect(result['PostOffice'], isList);
        expect((result['PostOffice'] as List).isNotEmpty, isTrue);
      });
    });

    group('API Response Handling', () {
      setUp(() {
        pinCodeModel = PinCodeModel(
          '110001',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        mockConnectivity.setConnectivityResponse(
          () async => [ConnectivityResult.wifi],
        );
      });

      test('should handle successful API response with valid data', () async {
        const mockResponse = [
          {
            'Status': 'Success',
            'PostOffice': [
              {
                'Name': 'Parliament House',
                'Pincode': '110001',
                'District': 'New Delhi',
                'State': 'Delhi',
                'Country': 'India',
              },
            ],
          },
        ];
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
              data: mockResponse,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Success'));
        expect(
          result['Message'],
          equals('PIN code data retrieved successfully'),
        );
        expect(result['PostOffice'], isNotNull);
        expect(result['PostOffice'], equals(mockResponse[0]['PostOffice']));
        expect(result['UserEnteredPin'], equals('110001'));
      });

      test('should handle API response with invalid PIN code', () async {
        const mockResponse = [
          {
            'Status': 'Error',
            'Message': 'No records found',
            'PostOffice': null,
          },
        ];
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
              data: mockResponse,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('No records found'));
        expect(result['PostOffice'], isNull);
        expect(result['UserEnteredPin'], equals('110001'));
      });

      test('should handle empty API response', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
              data: [],
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('Empty or unexpected API response'));
        expect(result['PostOffice'], isNull);
      });

      test('should handle malformed API response', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
              data: 'invalid response format',
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('Empty or unexpected API response'));
        expect(result['PostOffice'], isNull);
      });
    });

    group('Error Handling', () {
      setUp(() {
        pinCodeModel = PinCodeModel(
          '110001',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        mockConnectivity.setConnectivityResponse(
          () async => [ConnectivityResult.wifi],
        );
      });

      test('should handle connection timeout error', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionTimeout,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Connection timed out'));
        expect(result['PostOffice'], isNull);
      });

      test('should handle send timeout error', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.sendTimeout,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Send timed out'));
      });

      test('should handle receive timeout error', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.receiveTimeout,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Receive timed out'));
      });

      test('should handle bad response error', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: path),
                statusCode: 404,
              ),
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Bad response from server'));
      });

      test('should handle connection error', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionError,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Connection error'));
      });

      test('should handle SSL certificate error', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.badCertificate,
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('SSL certificate error'));
      });

      test('should handle unknown DioException', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.unknown,
              message: 'Unknown network error',
            );
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], contains('Unknown network error'));
      });

      test('should handle general exceptions', () async {
        mockDio.setGetResponse((
          String path,
          data,
          queryParameters,
          options,
          cancelToken,
          onReceiveProgress,
        ) async {
          if (path.contains('google.com')) {
            return Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 200,
            );
          } else if (path == 'pincode/110001') {
            throw Exception('General exception');
          }
          throw Exception('Unexpected path: $path');
        });
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(
          result['Message'],
          contains('A general error occurred: Exception: General exception'),
        );
      });
    });

    group('Resource Management', () {
      test('should dispose dio instance when dispose is called', () {
        bool closeCalled = false;
        mockDio.setCloseCallback(() {
          closeCalled = true;
        });
        final model = PinCodeModel(
          '110001',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        expect(() => model.dispose(), returnsNormally);
        expect(closeCalled, isTrue);
      });
    });
  });
}
