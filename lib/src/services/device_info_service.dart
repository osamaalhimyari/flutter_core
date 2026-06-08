import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Device fingerprint / metadata via device_info_plus. Built by `Core.init`
/// when [CoreService.deviceInfo] is enabled and returned on the `CoreContext`.
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<DeviceInfoModel> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final web = await _deviceInfo.webBrowserInfo;
        return DeviceInfoModel(
          deviceName: web.userAgent,
          platform: 'Web',
          brand: 'Web Browser',
          deviceModel: web.appName,
          manufacturer: 'Unknown',
          osVersion: web.appVersion,
          isPhysicalDevice: 'false',
        );
      } else if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        return DeviceInfoModel(
          deviceName: '${a.manufacturer} ${a.model}'.trim(),
          platform: 'Android',
          brand: a.brand,
          deviceModel: a.model,
          manufacturer: a.manufacturer,
          osVersion: a.version.release,
          sdkVersion: a.version.sdkInt.toString(),
          buildFingerprint: a.fingerprint,
          isPhysicalDevice: a.isPhysicalDevice.toString(),
        );
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        return DeviceInfoModel(
          deviceName: i.name,
          platform: 'iOS',
          brand: 'Apple',
          deviceModel: i.model,
          manufacturer: 'Apple',
          osVersion: i.systemVersion,
          sdkVersion: i.systemVersion,
          buildFingerprint: '${i.utsname.machine}-${i.utsname.release}',
          isPhysicalDevice: i.isPhysicalDevice.toString(),
        );
      } else if (Platform.isWindows) {
        final w = await _deviceInfo.windowsInfo;
        return DeviceInfoModel(
          deviceName: w.computerName,
          platform: 'Windows',
          brand: 'Unknown',
          deviceModel: 'Unknown',
          manufacturer: 'Unknown',
          osVersion: w.displayVersion,
          isPhysicalDevice: 'true',
        );
      } else if (Platform.isMacOS) {
        final m = await _deviceInfo.macOsInfo;
        return DeviceInfoModel(
          deviceName: m.computerName,
          platform: 'macOS',
          brand: 'Apple',
          deviceModel: m.model,
          manufacturer: 'Apple',
          osVersion: m.kernelVersion,
          isPhysicalDevice: 'true',
        );
      } else if (Platform.isLinux) {
        final l = await _deviceInfo.linuxInfo;
        return DeviceInfoModel(
          deviceName: l.name,
          platform: 'Linux',
          brand: 'Unknown',
          deviceModel: 'Unknown',
          manufacturer: 'Unknown',
          osVersion: l.version,
          isPhysicalDevice: 'true',
        );
      } else {
        return DeviceInfoModel(
          deviceName: 'Unknown Device',
          platform: 'Unknown',
          brand: 'Unknown',
          deviceModel: 'Unknown',
          manufacturer: 'Unknown',
          osVersion: 'Unknown',
          isPhysicalDevice: 'false',
        );
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return DeviceInfoModel(
        deviceName: 'Error Device',
        platform: 'Error',
        brand: 'Error',
        deviceModel: 'Error',
        manufacturer: 'Error',
        osVersion: 'Error',
        isPhysicalDevice: 'false',
      );
    }
  }
}

class DeviceInfoModel {
  final String? deviceName;
  final String? platform;
  final String? brand;
  final String? deviceModel;
  final String? manufacturer;
  final String? osVersion;
  final String? sdkVersion;
  final String? buildFingerprint;
  final String? isPhysicalDevice;

  DeviceInfoModel({
    required this.deviceName,
    required this.platform,
    required this.brand,
    required this.deviceModel,
    required this.manufacturer,
    this.osVersion,
    this.sdkVersion,
    this.buildFingerprint,
    required this.isPhysicalDevice,
  });

  Map<String, String?> toJson() => {
    'device_name': deviceName,
    'platform': platform,
    'brand': brand,
    'device_model': deviceModel,
    'manufacturer': manufacturer,
    'os_version': osVersion,
    'sdk_version': sdkVersion,
    'build_fingerprint': buildFingerprint,
    'is_physical_device': isPhysicalDevice,
  };

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) => DeviceInfoModel(
    deviceName: json['device_name'] as String?,
    platform: json['platform'] as String?,
    brand: json['brand'] as String?,
    deviceModel: json['device_model'] as String?,
    manufacturer: json['manufacturer'] as String?,
    osVersion: json['os_version'] as String?,
    sdkVersion: json['sdk_version'] as String?,
    buildFingerprint: json['build_fingerprint'] as String?,
    isPhysicalDevice: json['is_physical_device'] as String?,
  );
}
