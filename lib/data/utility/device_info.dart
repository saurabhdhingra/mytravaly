import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceUtility {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
        final deviceInfo = Platform.isIOS ?  await deviceInfoPlugin.iosInfo : await   deviceInfoPlugin.androidInfo;

        log(deviceInfo.data.toString());

        // USING DEFAULT DATA BECAUSE OF DISCREPANCIES IN ANDROID AND IOS DEVICE DATA STRUCTURES
        return {
            "deviceModel":"RMX3521",,
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
    }
  }
}
