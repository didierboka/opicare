// local_storage_service.dart
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:opicare/core/constants/log.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
final mylog  = MyLogger();

abstract class LocalStorageService {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getSavedUser();
  Future<void> clearUser();
}


class SharedPreferencesStorage implements LocalStorageService {


  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    mylog.logger.i("userData saved: ${jsonEncode(user.toJson())}");
    //print("userData: ${jsonEncode(user.toJson())}");
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }


  @override
  Future<UserModel?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null && userData.isNotEmpty) {
        final jsonData = jsonDecode(userData);

        // Validate that essential fields exist
        if (jsonData['ID'] != null && jsonData['ID'].toString().isNotEmpty) {
          UserModel user = UserModel.fromJson(jsonData);
          mylog.logger.i("Valid user data found in SharedPreferences: ${user.name}");
          return UserModel.fromJson(jsonData);
        }
      }

      mylog.logger.w("No valid user data found in SharedPreferences");
      return null;
    } catch (e) {
      mylog.logger.e("Error getting saved user: $e");
      return null;
    }
  }


  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}