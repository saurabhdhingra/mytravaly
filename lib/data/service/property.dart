import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mytravaly/data/utility/constants.dart';
import 'package:mytravaly/data/utility/network.dart';
import 'package:mytravaly/domain/property.dart';
import 'package:mytravaly/domain/search.dart';

class PropertyService {
  Future<List<Property>> fetchProperties(String visitorToken) async {
    final payload = {
      "action": "popularStay",
      "popularStay": {
        "limit": 10,
        "entityType": "Any",
        "filter": {
          "searchType": "byCountry",
          "searchTypeInfo": {"country": "India"},
        },
        "currency": "INR",
      },
    };

    try {
      final response = await CustomNetworkUtility.post(
        baseUrl(),
        payload,
        visitorToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] is List) {
          return (jsonResponse['data'] as List)
              .map((item) => Property.fromJson(item))
              .toList();
        } else {
          throw Exception('API returned success status but no valid data.');
        }
      } else {
        throw Exception(
          'Failed to load properties. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in fetching properties: $e');
      // Re-throw to be handled by the UI
      rethrow;
    }
  }

  // Method for Search Autocomplete
  Future<List<SearchResultItem>> searchAutoComplete(
    String inputText,
    String visitorToken,
  ) async {
    if (inputText.isEmpty) return [];

    final payload = {
      "action": "searchAutoComplete",
      "searchAutoComplete": {
        "inputText": inputText,
        "searchType": [
          "byCity",
          "byState",
          "byCountry",
          "byRandom",
          "byPropertyName",
        ],
        "limit": 10,
      },
    };

    try {
      final response = await CustomNetworkUtility.post(
        baseUrl(),
        payload,
        visitorToken,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          List<SearchResultItem> results = [];
          final autoCompleteList =
              jsonResponse['data']['autoCompleteList'] as Map<String, dynamic>?;

          if (autoCompleteList != null) {
            autoCompleteList.forEach((key, value) {
              if (value['present'] == true) {
                for (var item in (value['listOfResult'] as List)) {
                  results.add(SearchResultItem.fromJson(item));
                }
              }
            });
          }
          return results;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Autocomplete failed.');
        }
      } else {
        throw Exception(
          'Failed to perform autocomplete. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in autocomplete: $e');
      return [];
    }
  }

  // Method to fetch Search Results
Future<List<Property>> getSearchResultListOfHotels(
    SearchQueryData queryData,
    String visitorToken,
  ) async {
    final payload = {
      "action": "getSearchResultListOfHotels",
      "getSearchResultListOfHotels": {"searchCriteria": queryData.toJson()},
    };

    try {
      final response = await CustomNetworkUtility.post(
        // Replace with your actual baseUrl() implementation
        baseUrl(), 
        payload,
        visitorToken,
      );

      if (response.statusCode == 200) {
        debugPrint("Checkpoint 1: Received 200 OK");
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        debugPrint("Checkpoint 2: JSON Decoded");

        if (jsonResponse['status'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['arrayOfHotelList'] is List) {
          
          debugPrint("Checkpoint 3: Data structure validated. Starting mapping.");
          
          // Log the raw data if needed, but the error source (printing the Map 'item') is removed.
          // log(response.body); 

          final List<Property> hotelList = (jsonResponse['data']['arrayOfHotelList'] as List)
              .map((item) {
                // Safely cast item to the expected Map<String, dynamic> for fromJson
                debugPrint("Checkpoint 4 : Inside the map function.");
                final Map<String, dynamic> propertyJson = item as Map<String, dynamic>;
                return Property.fromJson(propertyJson);
              })
              .toList();
          
          debugPrint("Mapping complete. Returning list of ${hotelList.length} properties.");
          return hotelList; // Return the correctly parsed list

        } else {
          throw Exception(
            jsonResponse['message'] ??
                'API returned success status but no valid search results.',
          );
        }
      } else {
        throw Exception(
          'Failed to load search results. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Use kDebugMode check for printing stack trace if needed
      debugPrint('Error in fetching search results: $e');
      rethrow;
    }
  }
}
