import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> hasMicrophonePermission();
  Future<bool> requestMicrophonePermission();
  Future<bool> openAppSettings();
}

class AppPermissionService implements PermissionService {
  @override
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}

class MockPermissionService implements PermissionService {
  bool isGranted;
  MockPermissionService({this.isGranted = true});

  @override
  Future<bool> hasMicrophonePermission() async => isGranted;

  @override
  Future<bool> requestMicrophonePermission() async => isGranted;

  @override
  Future<bool> openAppSettings() async => true;
}
