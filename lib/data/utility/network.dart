import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mytravaly/data/utility/constants.dart';
import 'package:http/http.dart' as http;

class CustomNetworkUtility {
  /// Base headers required for the Mytravaly API.
  static Map<String, String> baseHeaders(String? visTok) {
    if (visTok == null) {
      return {'authtoken': authToken(), 'Content-Type': 'application/json'};
    } else {
      return {
        'visitortoken': visTok,
        'authtoken': authToken(),
        'Content-Type': 'application/json',
      };
    }
  }

  /// Performs a POST request to a specific endpoint.
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
    String? vistorToken,
  ) async {
    final uri = Uri.parse(endpoint);

    try {
      final response = await http.post(
        uri,
        headers: baseHeaders(vistorToken),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      // In a real app, you would log this error.
      debugPrint('Network error during POST to $endpoint: $e');
      throw Exception('Failed to connect to the network.');
    }
  }
}
