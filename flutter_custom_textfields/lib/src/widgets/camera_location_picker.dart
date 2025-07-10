import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/src/controllers/permission_controller.dart';
import 'package:flutter_custom_textfields/src/services/geocode_service.dart';
import 'package:flutter_custom_textfields/src/services/location_service.dart';
import 'package:flutter_custom_textfields/src/utils/watermark_util.dart';
import 'package:intl/intl.dart';

class CameraLocationResult {
  final File imageFile;
  final double? latitude;
  final double? longitude;
  final String? address;

  CameraLocationResult({
    required this.imageFile,
    this.latitude,
    this.longitude,
    this.address,
  });
}

class CameraLocationPicker extends StatefulWidget {
  final bool enableCamera;
  final bool enableLocation;
  final bool enableWatermark;
  final String? waterMarkText;
  final int? x;
  final int? y;
  final bool? displayLocation;
  final double? cameraHeight;
  final void Function(CameraLocationResult) onResult;

  const CameraLocationPicker({
    super.key,
    required this.enableCamera,
    required this.enableLocation,
    required this.enableWatermark,
    this.waterMarkText,
    required this.onResult,
    this.x,
    this.y,
    this.displayLocation = true,
    this.cameraHeight,
  });

  @override
  State<CameraLocationPicker> createState() => _CameraLocationPickerState();
}

class _CameraLocationPickerState extends State<CameraLocationPicker> {
  CameraController? _controller;
  XFile? _lastCapture;
  bool _isInitializing = false;
  bool _locationLoading = false;
  // double? _lat, _long;
  String? _address;
  bool _waterMarkOn = true;

  @override
  void initState() {
    super.initState();
    _waterMarkOn = widget.enableWatermark;
    if (widget.enableCamera && widget.enableLocation) {
      _fetchLocation();
      _initCamera();
    }
    if (widget.enableCamera && !widget.enableLocation) {
      _initCamera();
    }
    if (!widget.enableCamera && widget.enableLocation) {
      _fetchLocation();
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
    });
    final granted = await PermissionController.requestCamera();
    if (!granted) {
      setState(() {
        _isInitializing = false;
        return;
      });
    }
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (camera) {
        return camera.lensDirection == CameraLensDirection.back;
      },
      orElse: () {
        return cameras.first;
      },
    );
    _controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller?.initialize();
    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _locationLoading = true;
    });
    final locationGranted = await PermissionController.requestLocation();
    if (!locationGranted) {
      setState(() {
        _locationLoading = false;
        return;
      });
    }
    final locationPosition = await LocationService.getCurrentPosition();
    if (locationPosition != null) {
      final locationAddress = await GeocodeService.getAddressFromLatLng(
        locationPosition.latitude,
        locationPosition.longitude,
      );
      widget.onResult(
        CameraLocationResult(
          imageFile: File(""),
          latitude: locationPosition.latitude,
          longitude: locationPosition.longitude,
          address: locationAddress,
        ),
      );
      setState(() {
        // _lat = locationPosition.latitude;
        // _long = locationPosition.longitude;
        _address = locationAddress;
      });
    }
    setState(() {
      _locationLoading = false;
    });
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final raw = await _controller!.takePicture();
    File file = File(raw.path);

    /// Apply Water Mark
    if (widget.enableWatermark && _waterMarkOn) {
      final text =
          widget.waterMarkText ??
          DateFormat('yyyy-MM-dd - kk:mm').format(DateTime.now());
      file = await WatermarkUtil.applyWaterMark(
        file,
        '$_address \n $text',
        widget.x ?? 10,
        widget.y,
      );
    }
    double? lat, long;
    String? address;
    if (widget.enableLocation) {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        long = position.longitude;
        address = await GeocodeService.getAddressFromLatLng(lat, long);
      }
    }
    widget.onResult(
      CameraLocationResult(
        imageFile: file,
        latitude: lat,
        longitude: long,
        address: address,
      ),
    );
    setState(() {
      _lastCapture = raw;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableCamera && !widget.enableLocation) {
      return Center(child: Text('Nothing to display'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height *
                  (widget.cameraHeight ?? 1),
              maxWidth: double.infinity,
            ),
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildPreviewContent(),
            ),
          ),
        ),

        /// Bottom Controls
        // Padding(
        //   padding: EdgeInsets.symmetric(vertical: 12),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       // if (widget.enableWatermark)
        //       //   IconButton(
        //       //     onPressed: () {
        //       //       setState(() {
        //       //         _waterMarkOn = !_waterMarkOn;
        //       //       });
        //       //     },
        //       //     icon: Icon(
        //       //       _waterMarkOn
        //       //           ? Icons.water_damage
        //       //           : Icons.water_damage_outlined,
        //       //     ),
        //       //   ),
        //       if (widget.enableCamera)
        //         // FloatingActionButton(
        //         //   onPressed: _isInitializing ? null : _capture,
        //         //   child: Icon(Icons.camera_alt),
        //         // ),
        //         ElevatedButton.icon(
        //           onPressed: _isInitializing ? null : _capture,
        //           icon: Icon(Icons.camera_alt),
        //           label: Text("Open Camera"),
        //         ),
        //       if (!widget.enableCamera && widget.enableLocation)
        //         IconButton(
        //           onPressed: _locationLoading ? null : _fetchLocation,
        //           icon: Icon(Icons.location_searching),
        //         ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPreviewContent() {
    /// Camera Preview
    if (widget.enableCamera) {
      if (_isInitializing ||
          _controller == null ||
          !_controller!.value.isInitialized) {
        return Center(child: CircularProgressIndicator());
      }
      if (_lastCapture != null) {
        return Image.file(File(_lastCapture!.path), fit: BoxFit.contain);
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(_controller!),
          ),
          Positioned(
            bottom: 20,
            child: FloatingActionButton(
              onPressed: _capture,
              child: Icon(Icons.camera_alt),
            ),
          ),
        ],
      );
    }

    /// Location only view
    if (widget.enableLocation && widget.displayLocation!) {
      if (_locationLoading) {
        return Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   _lat != null && _long != null
            //       ? 'Lat: $_lat \n Long: $_long'
            //       : 'No Location',
            // ),
            if (_address != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  _address!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }

    if (widget.enableLocation && !widget.displayLocation!) {
      return SizedBox();
    }
    // Fall Back
    return Center(child: Text('Nothing'));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
