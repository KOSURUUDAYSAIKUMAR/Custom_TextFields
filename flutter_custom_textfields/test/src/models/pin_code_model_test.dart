import 'package:dio/dio.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'pin_code_model_test.mocks.dart';

@GenerateMocks([Dio, Connectivity])
void main() {
  late MockDio mockDio;
  late MockConnectivity mockConnectivity;
  late MockInterceptors mockInterceptors;
  late MockBaseOptions mockBaseOptions;
  late List<ConnectivityResult> connectivityResultForTest;

  final customMessages = CustomTextFieldsErrorMessages(
    emptyPincode: 'Please enter a PIN!',
    invalidPincodeFormat: 'Wrong PIN format!',
    noInternetConnection: 'No connection!',
    badAPIResponse: 'API issue!',
    connectivityCheckFailed: 'Conn check failed!',
    connectionTimeout: 'Connection timed out custom!',
    sendTimeout: 'Send timed out custom!',
    receiveTimeout: 'Receive timed out custom!',
    connectionError: 'Connection error custom!',
    sslCertificateError: 'SSL error custom!',
    unknownError: 'Unknown error custom!',
    generalError: 'General error custom!',
    invalidPincodeAPI: 'API invalid PIN!',
    emptyAPIResponse: 'Empty API response custom!',
  );

  setUpAll(() {});

  setUp(() {
    mockDio = MockDio();
    mockConnectivity = MockConnectivity();
    mockInterceptors = MockInterceptors();
    mockBaseOptions = MockBaseOptions();

    reset(mockDio);
    reset(mockConnectivity);
    mockInterceptors.clearInterceptors();
    mockBaseOptions = MockBaseOptions();
    connectivityResultForTest = [ConnectivityResult.wifi];
    when(mockConnectivity.checkConnectivity()).thenAnswer((_) async {
      return connectivityResultForTest;
    });
    when(mockDio.options).thenReturn(mockBaseOptions);
    when(mockDio.interceptors).thenReturn(mockInterceptors);
    when(mockDio.get(any, options: anyNamed('options'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: 'default'),
        statusCode: 200,
        data: [
          {'Status': 'Success', 'PostOffice': []},
        ],
      ),
    );
  });

  group('Valid PIN codes', () {
    test('should validate a correct PIN code (e.g., 123456)', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'pincode/$pinCode'),
          statusCode: 200,
          data: [
            {
              'Status': 'Success',
              'PostOffice': [
                {'Name': 'Office1', 'Pincode': pinCode},
              ],
            },
          ],
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Success'));
      expect(result['Message'], equals('PIN code data retrieved successfully'));
      expect(result['PostOffice'], isNotNull);
      expect((result['PostOffice'] as List).first['Pincode'], equals(pinCode));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should validate another correct PIN code (e.g., 987654)', () async {
      final pinCode = '987654';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'pincode/$pinCode'),
          statusCode: 200,
          data: [
            {
              'Status': 'Success',
              'PostOffice': [
                {'Name': 'Office2', 'Pincode': pinCode},
              ],
            },
          ],
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Success'));
      expect(result['PostOffice'], isNotNull);
      expect((result['PostOffice'] as List).first['Pincode'], equals(pinCode));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });
  });

  group('Invalid PIN codes', () {
    setUp(() {
      connectivityResultForTest = [ConnectivityResult.wifi];
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
    });

    test('should return error for PIN code with non-digit characters', () async {
      final pinCodeModel = PinCodeModel(
        '123abc',
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Invalid PIN code format'));
      expect(result['PostOffice'], isNull);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      // Using verifyNoMoreInteractions here is fine because no API call to pincode endpoint is expected
      // verifyNoMoreInteractions(mockDio);
    });

    test(
      'should return error for PIN code with incorrect length (too short)',
      () async {
        final pinCodeModel = PinCodeModel(
          '123',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('Invalid PIN code format'));
        expect(result['PostOffice'], isNull);
        verify(mockConnectivity.checkConnectivity()).called(1);
        verify(
          mockDio.get('https://www.google.com', options: anyNamed('options')),
        ).called(1);
      },
    );

    test(
      'should return error for PIN code with incorrect length (too long)',
      () async {
        final pinCodeModel = PinCodeModel(
          '1234567',
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('Invalid PIN code format'));
        expect(result['PostOffice'], isNull);
        verify(mockConnectivity.checkConnectivity()).called(1);
        verify(
          mockDio.get('https://www.google.com', options: anyNamed('options')),
        ).called(1);
      },
    );

    test('should return error for PIN code starting with 0', () async {
      final pinCodeModel = PinCodeModel(
        '012345',
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Invalid PIN code format'));
      expect(result['PostOffice'], isNull);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
    });
  });

  group('Initialization and Configuration', () {
    test(
      'should initialize with default dio and connectivity when not provided',
      () {
        final pinCodeModel = PinCodeModel('110001');
        expect(pinCodeModel, isA<PinCodeModel>());
      },
    );

    test('should initialize with provided dio and connectivity', () {
      final customDio = MockDio();
      final customConnectivity = MockConnectivity();
      final customMockBaseOptions = MockBaseOptions();
      when(customDio.options).thenReturn(customMockBaseOptions);
      when(customDio.interceptors).thenReturn(MockInterceptors());

      final pinCodeModel = PinCodeModel(
        '110001',
        dio: customDio,
        connectivity: customConnectivity,
      );
      print(pinCodeModel.toString());
      expect(
        customMockBaseOptions.baseUrl,
        equals('https://api.postalpincode.in/'),
      );
    });
  });

  group('Basic Validation', () {
    setUp(() {
      connectivityResultForTest = [ConnectivityResult.wifi];
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
    });

    test('should return error for invalid PIN code format', () async {
      final pinCodeModel = PinCodeModel(
        '123AB',
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Invalid PIN code format'));
      expect(result['PostOffice'], isNull);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      // verifyNoMoreInteractions(mockDio);
    });
    test('should return error for empty PIN code', () async {
      final pinCodeModel = PinCodeModel(
        '',
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('PIN code cannot be empty'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      // verifyNoMoreInteractions(mockDio);
    });
    test('should use custom message for empty PIN code', () async {
      final pinCodeModel = PinCodeModel(
        '',
        dio: mockDio,
        connectivity: mockConnectivity,
        customErrorMessages: customMessages,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Please enter a PIN!'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
    });

    test('should use custom message for invalid PIN code format', () async {
      final pinCodeModel = PinCodeModel(
        'abcde',
        dio: mockDio,
        connectivity: mockConnectivity,
        customErrorMessages: customMessages,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Wrong PIN format!'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
    });

    test('should use custom message for no internet connection', () async {
      connectivityResultForTest = [ConnectivityResult.none];
      final pinCodeModel = PinCodeModel(
        '123456',
        dio: mockDio,
        connectivity: mockConnectivity,
        customErrorMessages: customMessages,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('No connection!'));
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test(
      'should use custom message for bad API response (e.g., status 500)',
      () async {
        final testPin = '123456';
        when(
          mockDio.get('pincode/$testPin', options: anyNamed('options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'pincode/$testPin'),
            statusCode: 500,
          ),
        );
        final pinCodeModel = PinCodeModel(
          testPin,
          dio: mockDio,
          connectivity: mockConnectivity,
          customErrorMessages: customMessages,
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('API issue!'));
        verify(mockConnectivity.checkConnectivity()).called(1);
        verify(
          mockDio.get('https://www.google.com', options: anyNamed('options')),
        ).called(1);
        verify(
          mockDio.get('pincode/$testPin', options: anyNamed('options')),
        ).called(1);
      },
    );

    test(
      'should use custom message for API returning "Error" status',
      () async {
        final testPin = '123456';
        when(
          mockDio.get('pincode/$testPin', options: anyNamed('options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'pincode/$testPin'),
            statusCode: 200,
            data: [
              {'Status': 'Error', 'Message': 'Invalid Pincode provided by API'},
            ],
          ),
        );
        final pinCodeModel = PinCodeModel(
          testPin,
          dio: mockDio,
          connectivity: mockConnectivity,
          customErrorMessages: customMessages,
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('API invalid PIN!'));
        verify(mockConnectivity.checkConnectivity()).called(1);
        verify(
          mockDio.get('https://www.google.com', options: anyNamed('options')),
        ).called(1);
        verify(
          mockDio.get('pincode/$testPin', options: anyNamed('options')),
        ).called(1);
      },
    );

    test('should use custom message for empty API response', () async {
      final testPin = '123456';
      when(
        mockDio.get('pincode/$testPin', options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'pincode/$testPin'),
          statusCode: 200,
          data: [],
        ),
      );
      final pinCodeModel = PinCodeModel(
        testPin,
        dio: mockDio,
        connectivity: mockConnectivity,
        customErrorMessages: customMessages,
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Empty API response custom!'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      verify(
        mockDio.get('pincode/$testPin', options: anyNamed('options')),
      ).called(1);
    });
  });

  group('Internet Connectivity', () {
    test('should return error when no internet connection', () async {
      connectivityResultForTest = [ConnectivityResult.none];
      final pinCodeModel = PinCodeModel(
        '110001',
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      expect(mockDio.options.baseUrl, equals('https://api.postalpincode.in/'));
      expect(mockInterceptors.getInterceptors().length, equals(1));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('No internet connection'));
      expect(result['PostOffice'], isNull);
      expect(result['UserEnteredPin'], equals('110001'));
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('should proceed when internet connection is available', () async {
      connectivityResultForTest = [ConnectivityResult.wifi];
      final pinCodeModel = PinCodeModel(
        '530024',
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
      when(
        mockDio.get('pincode/530024', options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'pincode/530024'),
          statusCode: 200,
          data: [
            {
              'Status': 'Success',
              'PostOffice': [
                {'Name': 'OfficeX', 'Pincode': '530024'},
              ],
            },
          ],
        ),
      );
      expect(mockDio.options.baseUrl, equals('https://api.postalpincode.in/'));
      expect(mockInterceptors.getInterceptors().length, equals(1));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Success'));
      expect(result['PostOffice'], isNotNull);
      expect(result['PostOffice'], isList);
      expect((result['PostOffice'] as List).isNotEmpty, isTrue);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).called(1);
      verify(
        mockDio.get('pincode/530024', options: anyNamed('options')),
      ).called(1);
    });
  });

  group('API Response Handling', () {
    setUp(() {
      connectivityResultForTest = [ConnectivityResult.wifi];
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
    });

    test('should handle successful API response with valid data', () async {
      final validPin = '123456';
      final pinCodeModel = PinCodeModel(
        validPin,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$validPin', options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'pincode/$validPin'),
          statusCode: 200,
          data: [
            {
              'Status': 'Success',
              'PostOffice': [
                {
                  'Name': 'Test PO',
                  'Pincode': validPin,
                  'District': 'Test Dist',
                  'State': 'Test State',
                },
              ],
            },
          ],
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Success'));
      expect(result['Message'], equals('PIN code data retrieved successfully'));
      expect(result['PostOffice'], isNotNull);
      expect((result['PostOffice'] as List).length, equals(1));
      expect((result['PostOffice'] as List).first['Pincode'], equals(validPin));
      verify(
        mockDio.get('pincode/$validPin', options: anyNamed('options')),
      ).called(1);
    });
    test(
      'should handle API response with invalid PIN code (Status: Error from API)',
      () async {
        final validFormatButInvalidOnAPI = '123456';
        final pinCodeModel = PinCodeModel(
          validFormatButInvalidOnAPI,
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        when(
          mockDio.get(
            'pincode/$validFormatButInvalidOnAPI',
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'pincode/$validFormatButInvalidOnAPI',
            ),
            statusCode: 200,
            data: [
              {
                'Status': 'Error',
                'Message': 'No Post office found for the given Pincode',
              },
            ],
          ),
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(
          result['Message'],
          equals('No Post office found for the given Pincode'),
        );
        expect(result['PostOffice'], isNull);
        verify(
          mockDio.get(
            'pincode/$validFormatButInvalidOnAPI',
            options: anyNamed('options'),
          ),
        ).called(1);
      },
    );

    test('should handle empty API response (e.g., empty list)', () async {
      final pinCode = '111111';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'pincode/$pinCode'),
          statusCode: 200,
          data: [],
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Empty or unexpected API response'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test(
      'should handle malformed API response (e.g., non-list data or missing keys)',
      () async {
        final pinCode = '222222';
        final pinCodeModel = PinCodeModel(
          pinCode,
          dio: mockDio,
          connectivity: mockConnectivity,
        );
        when(
          mockDio.get('pincode/$pinCode', options: anyNamed('options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'pincode/$pinCode'),
            statusCode: 200,
            data: {'some_key': 'some_value'},
          ),
        );
        final result = await pinCodeModel.validatePinCode();
        expect(result['Status'], equals('Error'));
        expect(result['Message'], equals('Empty or unexpected API response'));
        expect(result['PostOffice'], isNull);
        verify(
          mockDio.get('pincode/$pinCode', options: anyNamed('options')),
        ).called(1);
      },
    );
  });

  group('Error Handling', () {
    DioException _createDioException(
      DioExceptionType type, {
      dynamic error,
      Response? response,
    }) {
      return DioException(
        requestOptions: RequestOptions(path: 'test_path'),
        type: type,
        error: error,
        response: response,
      );
    }

    setUp(() {
      connectivityResultForTest = [ConnectivityResult.wifi];
      when(
        mockDio.get('https://www.google.com', options: anyNamed('options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
    });

    test('should handle connection timeout error', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(_createDioException(DioExceptionType.connectionTimeout));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Connection timed out'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle send timeout error', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(_createDioException(DioExceptionType.sendTimeout));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Send timed out'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle receive timeout error', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(_createDioException(DioExceptionType.receiveTimeout));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Receive timed out'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle bad response error', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(
        _createDioException(
          DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: 'pincode/$pinCode'),
            statusCode: 400,
          ),
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Bad response from server'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle connection error', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(
        _createDioException(
          DioExceptionType.connectionError,
          error: SocketException('Failed host lookup'),
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Connection error'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle SSL certificate error', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(_createDioException(DioExceptionType.badCertificate));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('SSL certificate error'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle unknown DioException', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(
        _createDioException(
          DioExceptionType.unknown,
          error: Exception('Some unexpected error'),
        ),
      );
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(result['Message'], equals('Unknown network error'));
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });

    test('should handle general exceptions (non-DioException)', () async {
      final pinCode = '123456';
      final pinCodeModel = PinCodeModel(
        pinCode,
        dio: mockDio,
        connectivity: mockConnectivity,
      );
      when(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).thenThrow(Exception('A non-Dio error occurred'));
      final result = await pinCodeModel.validatePinCode();
      expect(result['Status'], equals('Error'));
      expect(
        result['Message'],
        contains(
          'A general error occurred: Exception: A non-Dio error occurred',
        ),
      );
      expect(result['PostOffice'], isNull);
      verify(
        mockDio.get('pincode/$pinCode', options: anyNamed('options')),
      ).called(1);
    });
  });
}

class MockBaseOptions extends Mock implements BaseOptions {
  String _baseUrl = '';
  @override
  String get baseUrl => _baseUrl;
  @override
  set baseUrl(String url) {
    _baseUrl = url;
  }

  @override
  Duration? connectTimeout;
  @override
  Duration? sendTimeout;
  @override
  Duration? receiveTimeout;
  Interceptors get interceptors =>
      MockInterceptors(); // This creates a new mock each time it's accessed!

  MockBaseOptions({
    String baseUrl = '',
    this.connectTimeout,
    this.sendTimeout,
    this.receiveTimeout,
  }) : _baseUrl = baseUrl;
}

class MockInterceptors extends Mock implements Interceptors {
  final List<Interceptor> _interceptors = [];
  @override
  void add(Interceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  bool any(bool Function(Interceptor element) test) {
    return _interceptors.any(test);
  }

  void clearInterceptors() => _interceptors.clear();
  List<Interceptor> getInterceptors() => List.unmodifiable(_interceptors);
}

class MockRequestOptions extends Mock implements RequestOptions {}
