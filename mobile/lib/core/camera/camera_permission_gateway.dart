import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionState { granted, denied, permanentlyDenied, restricted }

abstract interface class CameraPermissionGateway {
  Future<CameraPermissionState> request();
  Future<bool> openSettings();
}

class PermissionHandlerCameraPermissionGateway
    implements CameraPermissionGateway {
  const PermissionHandlerCameraPermissionGateway();

  @override
  Future<CameraPermissionState> request() async {
    var status = await Permission.camera.status;
    if (status.isDenied) status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) {
      return CameraPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return CameraPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) return CameraPermissionState.restricted;
    return CameraPermissionState.denied;
  }

  @override
  Future<bool> openSettings() => openAppSettings();
}
