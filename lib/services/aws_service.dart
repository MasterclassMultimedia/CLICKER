import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../aws_config.dart';
import '../models/clicker_data.dart';

class AWSService {
  static const String _prefsKey = 'clicker_data';
  
  // Save data to AWS DynamoDB via API Gateway
  static Future<bool> saveToAWS(ClickerData data) async {
    try {
      final response = await http.post(
        Uri.parse('${AWSConfig.apiGatewayUrl}/save'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AWSConfig.accessKey, // You might need an API key
        },
        body: jsonEncode(data.toJson()),
      );
      
      if (response.statusCode == 200) {
        // Also save locally as backup
        await _saveLocally(data);
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving to AWS: $e');
      // Fallback to local storage
      await _saveLocally(data);
      return false;
    }
  }

  // Load data from AWS DynamoDB via API Gateway
  static Future<ClickerData?> loadFromAWS(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('${AWSConfig.apiGatewayUrl}/load/$deviceId'),
        headers: {
          'x-api-key': AWSConfig.accessKey,
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ClickerData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error loading from AWS: $e');
      // Fallback to local storage
      return await _loadLocally();
    }
  }

  // Sync data - get latest from AWS and merge with local
  static Future<ClickerData> syncData(ClickerData localData) async {
    try {
      final awsData = await loadFromAWS(localData.deviceId);
      
      if (awsData != null) {
        // Compare timestamps and use the most recent
        if (awsData.lastUpdated.isAfter(localData.lastUpdated)) {
          // AWS data is newer, use it
          await _saveLocally(awsData);
          return awsData;
        } else {
          // Local data is newer, save to AWS
          await saveToAWS(localData);
          return localData;
        }
      } else {
        // No AWS data, save local to AWS
        await saveToAWS(localData);
        return localData;
      }
    } catch (e) {
      print('Error syncing data: $e');
      return localData;
    }
  }

  // Local storage methods
  static Future<void> _saveLocally(ClickerData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data.toJson()));
  }

  static Future<ClickerData?> _loadLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);
        return ClickerData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error loading local data: $e');
      return null;
    }
  }

  // Check if AWS is available
  static Future<bool> isAWSAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('${AWSConfig.apiGatewayUrl}/health'),
        headers: {
          'x-api-key': AWSConfig.accessKey,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
