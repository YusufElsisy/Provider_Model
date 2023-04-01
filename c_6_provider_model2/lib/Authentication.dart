import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Authentication with ChangeNotifier {
  String? _token;
  DateTime? _expiredDate;
  String? _userId;
  Timer? _expiredTimer;

  bool get auth {
    return token != null;
  }

  String? get token {
    if (_expiredDate != null &&
        _expiredDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> authMode(
      String email, String password, String urlSegment) async {
    Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCx9EgYdGDd7GKTJ2HuMO37x4zgn6bOd1U');
    try {
      var res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      if (json.decode(res.body)['error'] != null) {
        throw '${jsonDecode(res.body)['error']['message']}';
      }
      _token = json.decode(res.body)['idToken'];
      _expiredDate = DateTime.now().add(
          Duration(seconds: int.parse(json.decode(res.body)['expiresIn'])));
      _userId = json.decode(res.body)['localId'];

      autoLogOut();

      notifyListeners();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiredDate': _expiredDate!.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData').toString());
    final extractedTime = DateTime.parse(extractedData['expiredDate']);
    if (extractedTime.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiredDate = extractedTime;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return authMode(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return authMode(email, password, 'signInWithPassword');
  }

  void logOut() async {
    _token = null;
    _expiredDate = null;
    _userId = null;
    if (_expiredTimer != null) {
      _expiredTimer!.cancel();
      _expiredTimer = null;
    }

    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); //prefs.remove("userData");
  }

  void autoLogOut() {
    if (_expiredTimer != null) {
      _expiredTimer!.cancel();
    }

    final authTime = _expiredDate!.difference(DateTime.now()).inSeconds;
    _expiredTimer = Timer(Duration(seconds: authTime), logOut);
  }
}
