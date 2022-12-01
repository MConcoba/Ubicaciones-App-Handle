import 'dart:async';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locations/src/providers/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';

class Auth with ChangeNotifier {
  late String _token = '';
  late DateTime _expiryDate = DateTime.now().add(
    Duration(
      seconds: int.parse('50000'),
    ),
  );
  late String _userId = '';
  late Timer _authTimer = Timer(const Duration(seconds: 0), logout);
  late String _user = '';

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != '') {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      var response = await SqlConn.writeData(
          "EXEC  pmm_UsuarioValido '$email', '$password';");
      if (response) {
        _token = dotenv.get('TOKEN_APP');
        _userId = '0';
        _user = email;
        _expiryDate = DateTime.now().add(
          Duration(
            seconds: int.parse('50000'),
          ),
        );
      }
      notifyListeners();
      _autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
          'user': _user,
        },
      );
      prefs.setString('userData', userData);
      prefs.setString('userName', _user);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool> tryAutoLogin(ctx) async {
    bool a;
    final prefs = await SharedPreferences.getInstance();
    // logout();
    await Connection().setData();
    await Connection().reConnect();

    informationDevice();
    if (!prefs.containsKey('userData')) {
      a = false;
      // return false;
    } else {
      Map<String, dynamic> map =
          json.decode(prefs.getString('userData').toString());

      final expiryDate = DateTime.parse(map['expiryDate'].toString());

      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = map['token'].toString();
      _userId = map['userId'].toString();
      _user = map['user'].toString();
      _expiryDate = expiryDate;

      notifyListeners();
      _autoLogout();
      a = true;
    }
    return a;
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    // prefs.clear();
    notifyListeners();
  }

  void _autoLogout() async {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    await Connection().userConnect(_user);
  }

  void informationDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('device', androidInfo.id);
  }
}
