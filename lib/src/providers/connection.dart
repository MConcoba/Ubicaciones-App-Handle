import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:locations/src/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';

class Connection with ChangeNotifier {
  Future<void> setData() async {
    final prefs = await SharedPreferences.getInstance();
    bool ifr = await IsFirstRun.isFirstRun();

    print('se');
    print(ifr);
    notifyListeners();
    if (ifr) {
      prefs.setString('setting', dotenv.get("DB_QSSV_HOST"));
      prefs.setString('serve', dotenv.get("DB_QSSV_HOST"));
      prefs.setString('db', dotenv.get("DB_QSSV_DATABASE"));
      prefs.setString('user', dotenv.get("DB_QSSV_USERNAME"));
      prefs.setString('pass', dotenv.get("DB_QSSV_PASSWORD"));
    }
  }

  Future<void> reConnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (await SqlConn.isConnected) {
        log('es coneteado');
        return;
      }
      connect(
        prefs.getString("serve").toString(),
        prefs.getString("db").toString(),
        prefs.getString("user").toString(),
        prefs.getString("pass").toString(),
      );
    } catch (error) {
      throw error;
    }
  }

  Future<void> connect(
      String serve, String db, String user, String password) async {
    try {
      await SqlConn.connect(
        ip: serve,
        port: dotenv.get("DB_QSSV_PORT"),
        databaseName: db,
        username: user,
        password: password,
      );
      // return true;
    } catch (error) {
      log(error.toString());
      throw error;
    }
  }

  Future<void> save(String serve, String db, String user, String pass) async {
    return saveSettings(serve, db, user, pass);
  }

  Future<void> saveSettings(
      String serve, String db, String user, String pass) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
      return s;
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> getLocaion(String code) async {
    try {
      // print(code);
      var response = await SqlConn.readData(
          "SELECT * from Ubicaciones u WHERE Nombre = '$code'");
      final responseData = json.decode(response);
      if (response.length < 3) {
        throw HttpException('Location not found');
      }
      Map<String, dynamic> object = responseData[0] as Map<String, dynamic>;
      return object;
    } catch (error) {
      // print(error);
      throw error;
    }
  }

  Future<Map<String, dynamic>> postLocation(String code, String wr) async {
    try {
      // print(code);
      var response = await SqlConn.readData(
          "SELECT * from Ubicaciones u WHERE Nombre = '$code'");
      final responseData = json.decode(response);
      if (response.length < 3) {
        throw HttpException('Location not found');
      }
      Map<String, dynamic> object = responseData[0] as Map<String, dynamic>;
      return object;
    } catch (error) {
      // print(error);
      throw error;
    }
  }
}
