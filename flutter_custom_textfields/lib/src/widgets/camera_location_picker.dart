import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_textfields/src/models/camera_mode.dart';
import 'package:geolocator/geolocator.dart';
import '../../flutter_custom_textfields.dart';
import '../controllers/permission_controller.dart';
import '../services/location_service.dart';
import '../services/geocode_service.dart';
import '../utils/watermark_util.dart';

typedef LocationImageCallback =
    void Function(File? image, double? lat, double? lng, String? address);

class CameraLocationPicker extends StatefulWidget {
  final bool enableLocation;
  final bool enableCamera;
  final bool enableWatermark;
  final LocationImageCallback callback;
  final Widget? noCameraView;
  final String? locationErrorMessage;
  final CameraMode cameraMode;

  const CameraLocationPicker({
    super.key,
    required this.enableLocation,
    required this.enableCamera,
    required this.enableWatermark,
    required this.callback,
    this.noCameraView,
    this.locationErrorMessage = 'Location unavailable',
    this.cameraMode = CameraMode.rear,
  });

  @override
  State<CameraLocationPicker> createState() => _CameraLocationPickerState();
}

class _CameraLocationPickerState extends State<CameraLocationPicker>
    with WidgetsBindingObserver {
  // CameraMode _currentCameraMode = CameraMode.rear;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  bool _isCapturing = false;
  String? _error;
  String? _locationError;
  DeviceOrientation? _deviceOrientation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.enableCamera && widget.enableLocation) {
      _fetchLocationOnly(); // skip UI, directly fetch
    } else {
      // _currentCameraMode = widget.cameraMode;
      _initializePermissions(); // camera init
    }
  }

  Future<void> _initializePermissions() async {
    try {
      if (widget.enableCamera) {
        await PermissionController.requestCamera();
      }
      if (widget.enableLocation) {
        await PermissionController.requestLocation();
      }
      _initialize();
    } catch (e) {
      setState(() {
        _error = 'Permission error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null; // Prevent usage after dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializePermissions();
    }
  }

  @override
  void didChangeMetrics() {
    _updateOrientation();
  }

  void _updateOrientation() {
    if (_isDisposed) return;

    final mediaQuery = MediaQuery.of(context);
    DeviceOrientation orientation;

    if (mediaQuery.size.width > mediaQuery.size.height) {
      orientation = DeviceOrientation.landscapeLeft;
    } else {
      orientation = DeviceOrientation.portraitUp;
    }

    if (_deviceOrientation != orientation) {
      setState(() {
        _deviceOrientation = orientation;
      });
    }
  }

  Future<void> _initialize() async {
    if (_isDisposed) return;

    try {
      if (widget.enableCamera) {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          final selectedCamera = _cameras!.firstWhere(
            (cam) => cam.lensDirection == widget.cameraMode.lensDirection,
            orElse: () => _cameras!.first,
          );
          _controller = CameraController(
            selectedCamera,
            ResolutionPreset.high,
            enableAudio: false,
          );
          await _controller!.initialize();

          if (_isDisposed) return;
          _updateOrientation();
        } else {
          if (!_isDisposed) {
            setState(() {
              _error = 'No cameras available';
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (!_isDisposed) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _error = 'Initialization failed: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _setCameraController() async {
  //   if (_cameras == null || _cameras!.isEmpty) return;
  //   final camera = _cameras!.firstWhere(
  //     (cam) {
  //       return cam.lensDirection == _currentCameraMode.lensDirection;
  //     },
  //     orElse: () {
  //       return _cameras!.first;
  //     },
  //   );
  //   await _controller?.dispose();
  //   _controller = CameraController(camera, ResolutionPreset.high);
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // Future<void> _switchCamera() async {
  //   if (_cameras == null || _cameras!.length < 2) return;
  //   setState(() {
  //     _currentCameraMode =
  //         _currentCameraMode == CameraMode.rear
  //             ? CameraMode.front
  //             : CameraMode.rear;
  //   });
  //   await _setCameraController();
  // }

  Future<void> _fetchLocationOnly() async {
    final position = await _getLocation();
    String? address;
    if (position != null) {
      address = await _getAddress(position);
    }
    widget.callback(null, position?.latitude, position?.longitude, address);
    // Optionally: Close the screen
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<Position?> _getLocation() async {
    try {
      final permissionGranted = await PermissionController.requestLocation();
      if (!permissionGranted) {
        _locationError = 'Location permission denied';
        return null;
      }
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        _locationError = 'Location services disabled';
        return null;
      }
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        _locationError = 'Could not retrieve location';
      }
      return position;
    } catch (e) {
      _locationError = 'Location error: ${e.toString()}';
      return null;
    }
  }

  Future<String?> _getAddress(Position position) async {
    try {
      final positionAddress = await GeocodeService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      return positionAddress;
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      Position? position;
      String? address;

      if (widget.enableLocation) {
        position = await _getLocation();
        if (position != null) {
          address = await _getAddress(position);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_locationError ?? widget.locationErrorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      File? imageFile;
      if (widget.enableCamera) {
        if (_controller == null || !_controller!.value.isInitialized) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera not ready'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final image = await _controller!.takePicture();
        imageFile = File(image.path);

        // Apply watermark if needed
        if (widget.enableLocation &&
            widget.enableWatermark &&
            position != null) {
          imageFile = await WatermarkUtil.addWatermark(
            imageFile: imageFile,
            lat: position.latitude,
            lng: position.longitude,
            address: address ?? widget.locationErrorMessage!,
          );
        }
      }
      widget.callback(
        imageFile,
        position?.latitude,
        position?.longitude,
        address,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Widget _buildCameraPreview() {
    if (_controller == null ||
        _isDisposed ||
        !_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Camera not available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Add top margin to avoid status bar
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CameraLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cameraMode != oldWidget.cameraMode) {
      _initializePermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableCamera && widget.enableLocation) {
      // return const SizedBox.shrink();
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching location...'),
            ],
          ),
        ),
      );
    }
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing camera...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _initializePermissions();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Handle different operation modes
    if (!widget.enableCamera && !widget.enableLocation) {
      return widget.noCameraView ?? const SizedBox.shrink();
    }

    // if (!widget.enableCamera && widget.enableLocation) {
    //   return const SizedBox.shrink();

    //   // return Scaffold(
    //   //   body: Center(
    //   //     child: Column(
    //   //       mainAxisAlignment: MainAxisAlignment.center,
    //   //       children: [
    //   //         const Icon(Icons.location_on, size: 64, color: Colors.blue),
    //   //         const SizedBox(height: 24),
    //   //         const Text(
    //   //           'Get Current Location',
    //   //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //   //         ),
    //   //         const SizedBox(height: 16),
    //   //         ElevatedButton.icon(
    //   //           onPressed: () async {
    //   //             final position = await _getLocation();
    //   //             String? address;

    //   //             if (position != null) {
    //   //               address = await _getAddress(position);
    //   //             }

    //   //             widget.callback(
    //   //               null,
    //   //               position?.latitude,
    //   //               position?.longitude,
    //   //               address,
    //   //             );
    //   //           },
    //   //           icon: const Icon(Icons.location_searching),
    //   //           label: const Text('Get Location'),
    //   //           style: ElevatedButton.styleFrom(
    //   //             padding: const EdgeInsets.symmetric(
    //   //               horizontal: 32,
    //   //               vertical: 16,
    //   //             ),
    //   //           ),
    //   //         ),
    //   //         if (_locationError != null)
    //   //           Padding(
    //   //             padding: const EdgeInsets.all(16.0),
    //   //             child: Text(
    //   //               _locationError!,
    //   //               style: const TextStyle(color: Colors.red),
    //   //               textAlign: TextAlign.center,
    //   //             ),
    //   //           ),
    //   //       ],
    //   //     ),
    //   //   ),
    //   // );
    // }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview that fills the screen, but respects status bar
          Positioned(
            top: MediaQuery.of(context).padding.top, // Start below status bar
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCameraPreview(),
          ),

          //  Top status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      if (widget.enableLocation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Location ON',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120 + MediaQuery.of(context).padding.bottom,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: SafeArea(child: _buildCameraControls()),
            ),
          ),

          // Loading indicator
          if (_isCapturing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Capturing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              // Container(
              //   width: 56,
              //   height: 56,
              //   decoration: BoxDecoration(
              //     color: Colors.black.withOpacity(0.3),
              //     borderRadius: BorderRadius.circular(28),
              //     border: Border.all(color: Colors.white, width: 2),
              //   ),
              //   child: IconButton(
              //     onPressed: () {
              //       // You can add gallery functionality here
              //     },
              //     icon: const Icon(Icons.photo_library, color: Colors.white),
              //   ),
              // ),

              // Capture button
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // // Switch camera button
              // Container(
              //   width: 56,
              //   height: 56,
              //   decoration: BoxDecoration(
              //     color: Colors.black.withOpacity(0.3),
              //     borderRadius: BorderRadius.circular(28),
              //     border: Border.all(color: Colors.white, width: 2),
              //   ),
              //   child: IconButton(
              //     onPressed: () {
              //       _switchCamera();
              //     },
              //     icon: Icon(
              //       _currentCameraMode == CameraMode.rear
              //           ? Icons.flip_camera_ios
              //           : Icons.flip_camera_android,
              //       color: Colors.white,
              //       size: 28,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 30),
          // if (widget.enableLocation)
          //   Text(
          //     'Location will be embedded in the image',
          //     style: TextStyle(
          //       color: Colors.white.withOpacity(0.8),
          //       fontSize: 12,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
