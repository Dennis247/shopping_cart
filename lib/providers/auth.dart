import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider_pattern/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _apiKey = "AIzaSyBVxWjb6WHgteoB3oyawAT-yu0PuH5CoIk";
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  String _email;

  bool get isAuth {
    return token != null;
  }

  String get email {
    return _email;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticateUser(
      String email, String password, String urlSegment) async {
    final String _signUpUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$_apiKey";
    try {
      final response = await http.post(_signUpUrl,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      // print(response.body);
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _email = email;
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogOut();

      final sharedPrefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
        'email': email
      });

      sharedPrefs.setString('userData', userData);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    final sharedPref = await SharedPreferences.getInstance();
    if (!sharedPref.containsKey('userData')) {
      return false;
    }
    final sharedData = sharedPref.getString('userData');
    final extractedUserData = json.decode(sharedData) as Map<String, Object>;
    final exipiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (exipiryDate.isBefore(DateTime.now())) return false;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = exipiryDate;
    _email = extractedUserData['email'];
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    await _authenticateUser(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    await _authenticateUser(email, password, "signInWithPassword");
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _email = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
