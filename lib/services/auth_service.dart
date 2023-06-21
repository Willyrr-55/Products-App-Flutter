import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {

  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyDt0S5j7C3BcBy2VVdgP00HcRqIoR02lbA';

  final storage = const FlutterSecureStorage();

// IF WE RETURN SOMETHING IT WILL BE BECAUSE WE HAVE AN ERROR
  Future<String?> createUser(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken':true
    };
    final url =
        Uri.https(_baseUrl, '/v1/accounts:signUp', {'key': _firebaseToken});

    final resp = await http.post(url, body: json.encode(authData));
    final Map<String, dynamic> decodeResp = json.decode(resp.body);

    // print(decodeResp);
    if(decodeResp.containsKey('idToken')){
      storage.write(key: 'token', value: decodeResp['idToken']);
      // We must to save token in a safe place.
      // decodeResp['idToken'];
      return null;
    }else{
      return decodeResp['error']['message'];
    }
  }

  Future<String?> login(String email, String password) async {

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken':true
    };
    final url =
        Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {'key': _firebaseToken}); 

    final resp = await http.post(url, body: json.encode(authData));
    final Map<String, dynamic> decodeResp = json.decode(resp.body);

    // print(decodeResp);
    if(decodeResp.containsKey('idToken')){
      storage.write(key: 'token', value: decodeResp['idToken']);
      // We must to save token in a safe place.
      // decodeResp['idToken'];
      return null;
    }else{
      return decodeResp['error']['message'];
    }
  }

  Future logout() async{
    await storage.delete(key: 'token');
    return ;
  }

  Future<String> readToken() async{
    return await storage.read(key: 'token') ?? '';
  }

}
