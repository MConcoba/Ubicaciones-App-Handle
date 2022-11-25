import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting with ChangeNotifier {
  Future<void> save(String serve, String db, String user, String pass) async {
    return saveSettings(serve, db, user, pass);
  }

  Future<void> saveSettings(
      String serve, String db, String user, String pass) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final LocalStorage storage = new LocalStorage('todo_app');
      final userData = json.encode(
        {
          'serve': serve,
          'db': db,
          'user': user,
          'pass': pass,
        },
      );
      notifyListeners();
      prefs.setString('setting', userData);
      prefs.setString('serve', serve);
      prefs.setString('db', db);
      prefs.setString('user', user);
      prefs.setString('pass', pass);

      /* await storage.clear();

      storage.setItem('serve', serve);
      storage.setItem('db', db);
      storage.setItem('user', user);
      storage.setItem('pass', pass); */

      String? token = prefs.getString('setting');
      print(token);
    } catch (error) {
      throw error;
    }
  }

  Future<Object> returnSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = json.decode(prefs.getString('setting').toString())
          as Map<String, Object>;
      //final expiryDate = DateTime.parse(extractedUserData['expiryDate'].toString());
      return s;
    } catch (error) {
      throw error;
    }
  }
}
