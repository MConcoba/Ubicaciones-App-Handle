import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:locations/src/providers/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  late String _token = '';
  late DateTime _expiryDate = DateTime.now().add(
    Duration(
      seconds: int.parse('50000'),
    ),
  );
  late String _userId = '';
  late Timer _authTimer = Timer(const Duration(seconds: 0), logout);

  bool get isAuth {
    print(_token);
    print(token != null);
    // notifyListeners();
    return token != null;
  }

  String? get token {
    print(_token);
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
      print(email);
      var response = await SqlConn.readData(
          "SELECT * FROM  Usuarios u WHERE [Login] = '$email'");
      print(response);
      if (response.length > 0) {
        final responseData = json.decode(response);
        if (responseData[0]['error'] != null) {
          print(responseData[0]['Clave']);
          throw HttpException(responseData['error']['message']);
        }
        _token = responseData[0]['Clave'].toString();
        _userId = responseData[0]['UsuarioId'].toString();
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
        },
      );
      prefs.setString('userData', userData);
      print(prefs.getString('userData'));
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
    /*  print(email);
    var res = await SqlConn.readData(
        "SELECT * FROM  Usuarios u WHERE [Login] = '$email'");
    if (res.length > 0) {
      print('object');
    } */
  }

  Future<bool> tryAutoLogin(ctx) async {
    bool a;
    final prefs = await SharedPreferences.getInstance();
    await Connection().setData();
    await Connection().reConnect();
    if (!prefs.containsKey('userData')) {
      a = false;
    } else {
      Map<String, dynamic> map =
          json.decode(prefs.getString('userData').toString());

      print(map);
      final expiryDate = DateTime.parse(map['expiryDate'].toString());

      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = map['token'].toString();
      _userId = map['userId'].toString();
      _expiryDate = expiryDate;
      notifyListeners();
      _autoLogout();
      a = true;
    }
    print(a);
    return a;
  }

  Future<void> logout() async {
    print('log');
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    print(_authTimer.toString());
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
    //  print(prefs.containsKey('userData'));
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
