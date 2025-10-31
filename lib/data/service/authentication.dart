import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:mytravaly/data/utility/constants.dart';
import 'package:mytravaly/data/utility/device_info.dart';
import 'package:mytravaly/data/utility/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SharedPreferences _prefs;

  AuthService(this._prefs);


  Future<String?> registerDevice() async {
    final deviceData = await DeviceUtility.getDeviceInfo(); 

    final payload = {
      "action": "deviceRegister",
      "deviceRegister": deviceData, 
    };

    try {
      final response = await CustomNetworkUtility.post(baseUrl(), payload, null);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data']['visitorToken'] != null) {
          final visitorToken = data['data']['visitorToken'] as String;
          await _saveVisitorToken(visitorToken);
          return visitorToken;
        } else {
          debugPrint('API Error: ${data['message']}');
          return null;
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Registration Failed: $e');
      return null;
    }
  }

  Future<void> _saveVisitorToken(String token) async {
    await _prefs.setString(visitorTokenKey(), token);
    debugPrint('Visitor Token saved: $token');
  }

  String? getVisitorToken() {
    return _prefs.getString(visitorTokenKey());
  }
  
  Future<void> clearVisitorToken() async {
    await _prefs.remove(visitorTokenKey());
    debugPrint('Visitor Token removed from storage.');
  }
}
