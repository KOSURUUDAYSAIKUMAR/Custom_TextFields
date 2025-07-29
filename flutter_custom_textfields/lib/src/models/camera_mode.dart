import 'package:camera/camera.dart';

enum CameraMode { rear, front }

extension CameraModeExtension on CameraMode {
  CameraLensDirection get lensDirection {
    switch (this) {
      case CameraMode.rear:
        return CameraLensDirection.back;
      case CameraMode.front:
        return CameraLensDirection.front;
    }
  }

  String get cameraModeName {
    switch (this) {
      case CameraMode.rear:
        return 'Rear Camera';
      case CameraMode.front:
        return 'Front Camera';
    }
  }
}
