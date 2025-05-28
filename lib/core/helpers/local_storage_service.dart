// local_storage_service.dart
import 'dart:convert';

import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getSavedUser();
  Future<void> clearUser();
}

class SharedPreferencesStorage implements LocalStorageService {
  @override
  Future<void> saveUser(UserModel user) async {

    final prefs = await SharedPreferences.getInstance();
    print("userData: ${jsonEncode(user.toJson())}");
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}