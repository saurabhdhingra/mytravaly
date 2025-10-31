// Auth Service

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mytravaly/data/utility/constants.dart';
import 'package:mytravaly/data/utility/device_info.dart';
import 'package:mytravaly/data/utility/network.dart';


class AuthService {
  final FlutterSecureStorage _storage;

  AuthService(this._storage);


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
    // Securely save the token using FlutterSecureStorage
    await _storage.write(key: visitorTokenKey(), value: token);
    debugPrint('Visitor Token saved: $token');
  }

  Future<String?> getVisitorToken() async {
    // Securely read the token using FlutterSecureStorage
    return await _storage.read(key: visitorTokenKey());
  }
  
  Future<void> clearVisitorToken() async {
    // Securely delete the token using FlutterSecureStorage
    await _storage.delete(key: visitorTokenKey());
    debugPrint('Visitor Token removed from storage.');
  }
}
