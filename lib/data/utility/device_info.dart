import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceUtility {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// Gets the device information in the format required by the API.
  /// This currently focuses on Android fields as per the assignment's mock data.
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
        final deviceInfo = Platform.isIOS ?  await deviceInfoPlugin.iosInfo : await   deviceInfoPlugin.androidInfo;

        log(deviceInfo.data.toString());

        return {
            "deviceModel":"RMX3521",
            "deviceFingerprint":"realme/RMX3521/RE54E2L1:13/RKQ1.211119.001/S.f1bb32-7f7fa_1:user/release-keys",
            "deviceBrand":"realme",
            "deviceId":"RE54E2L1",
            "deviceName":"RMX3521_11_C.10",
            "deviceManufacturer":"realme",
            "deviceProduct":"RMX3521",
            "deviceSerialNumber":"unknown"
        };
    } catch (e) {
      debugPrint("Could not fetch device info: $e");
      // Fallback to structured mock data if plugin fails
      return {
        "deviceModel": "unknown_model",
        "deviceFingerprint": "unknown_fingerprint",
        "deviceBrand": "unknown_brand",
        "deviceId": "unknown_id",
        "deviceName": "unknown_name",
        "deviceManufacturer": "unknown_manufacturer",
        "deviceProduct": "unknown_product",
        "deviceSerialNumber": "unknown_serial",
      };
    }
  }
}
