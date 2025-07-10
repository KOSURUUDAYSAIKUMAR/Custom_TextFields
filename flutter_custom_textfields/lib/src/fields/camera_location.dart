// lib/camera_with_location.dart
import 'dart:io';
import 'dart:async';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img; // Alias for image package

// Global variable to store the list of available cameras
List<CameraDescription> cameras = [];

/// Initializes the available cameras on the device.
/// This function should be called before running the app or using CameraWithLocationWidget.
Future<void> initializeCameras() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error initializing cameras: $e');
  }
}

/// A Flutter widget that provides camera functionality with optional location watermarking.
class CameraWithLocationWidget extends StatefulWidget {
  final bool
  showLocationWatermark; // Controls whether to add location watermark
  final Function(String? imagePath)?
  onPictureTaken; // Callback when picture is taken

  const CameraWithLocationWidget({
    super.key,
    this.showLocationWatermark = true,
    this.onPictureTaken,
  });

  @override
  State<CameraWithLocationWidget> createState() =>
      _CameraWithLocationWidgetState();
}

class _CameraWithLocationWidgetState extends State<CameraWithLocationWidget>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  Position? _currentPosition;
  String _currentAddress = 'Fetching location...';
  bool _isLocationEnabled = true; // State for the location watermark toggle
  XFile? _capturedImage; // Stores the captured image file
  bool _isCameraReady = false; // Tracks if the camera is initialized and ready

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLocationEnabled =
        widget.showLocationWatermark; // Initialize toggle state
    _initializeCameraAndLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changes include going to background, foreground, etc.
    final CameraController? cameraController = _cameraController;

    // App state is not running.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Dispose of the controller when the app is inactive.
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the controller when the app resumes.
      _initializeCameraAndLocation();
    }
  }

  /// Initializes both camera and location services.
  Future<void> _initializeCameraAndLocation() async {
    if (cameras.isEmpty) {
      await initializeCameras(); // Ensure cameras are initialized if not already
    }

    if (cameras.isEmpty) {
      setState(() {
        _isCameraReady = false;
      });
      _showMessage('No cameras found on this device.', isError: true);
      return;
    }

    // Select the first available camera (usually back camera)
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false, // No audio needed for photo app
    );

    _initializeControllerFuture = _cameraController!
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isCameraReady = true;
          });
          if (_isLocationEnabled) {
            _getCurrentLocation();
          }
        })
        .catchError((e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                _showMessage(
                  'Camera access denied. Please grant permission in settings.',
                  isError: true,
                );
                break;
              default:
                _showMessage(
                  'Error initializing camera: ${e.description}',
                  isError: true,
                );
                break;
            }
          } else {
            _showMessage('An unexpected error occurred: $e', isError: true);
          }
          setState(() {
            _isCameraReady = false;
          });
        });
  }

  /// Gets the current GPS location and reverse geocodes it to an address.
  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentAddress = 'Fetching location...';
    });
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage(
        'Location services are disabled. Please enable them.',
        isError: true,
      );
      setState(() {
        _currentAddress = 'Location services disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage(
          'Location permissions are denied. Cannot watermark with location.',
          isError: true,
        );
        setState(() {
          _currentAddress = 'Location permission denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(
        'Location permissions are permanently denied. Cannot watermark with location.',
        isError: true,
      );
      setState(() {
        _currentAddress = 'Location permission permanently denied.';
      });
      return;
    }

    try {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _currentAddress =
              "Address not found for coordinates: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
        });
      }
    } catch (e) {
      _showMessage('Error getting location: $e', isError: true);
      setState(() {
        _currentAddress = 'Failed to get location.';
      });
    }
  }

  /// Takes a picture and optionally adds a location watermark.
  Future<void> _takePicture() async {
    if (!_isCameraReady ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      _showMessage('Camera not ready. Please wait.', isError: true);
      return;
    }

    try {
      await _initializeControllerFuture; // Ensure camera is initialized
      final XFile imageFile = await _cameraController!.takePicture();

      if (_isLocationEnabled &&
          _currentPosition != null &&
          _currentAddress != 'Fetching location...' &&
          _currentAddress != 'Failed to get location.' &&
          _currentAddress != 'Location permission denied.' &&
          _currentAddress != 'Location permission permanently denied.' &&
          _currentAddress != 'Location services disabled.') {
        // Add watermark
        final String? watermarkedImagePath = await _addWatermark(
          imageFile.path,
          _currentAddress,
        );
        setState(() {
          _capturedImage = XFile(
            watermarkedImagePath ?? imageFile.path,
          ); // Use watermarked path if successful
        });
        widget.onPictureTaken?.call(watermarkedImagePath ?? imageFile.path);
      } else {
        // No watermark
        setState(() {
          _capturedImage = imageFile;
        });
        widget.onPictureTaken?.call(imageFile.path);
      }
      _showMessage('Picture captured!', isError: false);
    } catch (e) {
      _showMessage('Error taking picture: $e', isError: true);
    }
  }

  /// Adds a text watermark to an image.
  Future<String?> _addWatermark(String imagePath, String watermarkText) async {
    try {
      final File originalImageFile = File(imagePath);
      // Convert List<int> to Uint8List for img.decodeImage
      Uint8List imageBytes = Uint8List.fromList(
        await originalImageFile.readAsBytes(),
      );
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print('Could not decode image.');
        return null;
      }

      // Determine text color based on image brightness (simple heuristic)
      // Calculate average brightness of the bottom part of the image
      int startY = (originalImage.height * 0.9).toInt(); // Start from 90% down
      int endY = originalImage.height;
      int totalBrightness = 0;
      int pixelCount = 0;

      for (int y = startY; y < endY; y++) {
        for (int x = 0; x < originalImage.width; x++) {
          final pixel = originalImage.getPixel(x, y);
          // Cast num to int
          totalBrightness += img.getLuminance(pixel).toInt();
          pixelCount++;
        }
      }

      final double averageBrightness =
          pixelCount > 0 ? totalBrightness / pixelCount : 0;
      final img.Color textColor =
          averageBrightness > 128
              ? img.ColorRgb8(0, 0, 0)
              : img.ColorRgb8(
                255,
                255,
                255,
              ); // Black for bright, white for dark

      // Define font size and position
      final img.BitmapFont font =
          img.arial24; // You can choose other fonts or load custom ones
      final int textX = 10; // Padding from left
      final int textY =
          originalImage.height - font.lineHeight - 10; // Padding from bottom

      // Draw text on the image
      img.drawString(
        originalImage,
        font: font,
        x: textX,
        y: textY,
        watermarkText,
        color: textColor,
      );

      // Save the watermarked image
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String watermarkedImagePath =
          '${appDocDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File watermarkedImageFile = File(watermarkedImagePath);
      await watermarkedImageFile.writeAsBytes(img.encodeJpg(originalImage));

      return watermarkedImagePath;
    } catch (e) {
      print('Error adding watermark: $e');
      return null;
    }
  }

  /// Displays a message using a SnackBar.
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_isCameraReady && _cameraController!.value.isInitialized) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_cameraController!)),
                // Location watermark toggle
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLocationEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLocationEnabled ? 'Location ON' : 'Location OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: _isLocationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isLocationEnabled = value;
                              if (value) {
                                _getCurrentLocation(); // Fetch location if enabled
                              } else {
                                _currentAddress =
                                    'Location watermarking disabled.';
                              }
                            });
                          },
                          activeColor: Colors.blueAccent,
                          inactiveTrackColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                // Current location display
                Positioned(
                  bottom: 100.0, // Above the capture button
                  left: 16.0,
                  right: 16.0,
                  child: Visibility(
                    visible: _isLocationEnabled,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _currentAddress,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                // Capture button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      backgroundColor: Colors.blueAccent,
                      child: const Icon(Icons.camera_alt, size: 36),
                    ),
                  ),
                ),
                // Captured image preview
                if (_capturedImage != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black, // Dark background for preview
                      child: Center(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(File(_capturedImage!.path)),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _capturedImage = null; // Clear preview
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            // Show a loading indicator or an error message if camera is not ready
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        } else {
          // While the future is still running
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading camera...', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }
      },
    );
  }
}
