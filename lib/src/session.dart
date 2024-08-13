import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/server_uri.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SessionGoogle {
  String username = 'anonymous';
  ImageProvider url = const AssetImage('assets/images/ExampleLogo.png');
  String token = '';
  SessionGoogle();

  Future<void> initialize() async {
    const storage = FlutterSecureStorage();
    String? username = await storage.read(key: "username");
    String? urlString = await storage.read(key: "url");
    String? token = await storage.read(key: "token");

    this.username = username ?? "anonymous";
    this.token = token ?? "anonymous";
    url = urlString != null
        ? NetworkImage(urlString)
        : const AssetImage('assets/images/ExampleLogo.png');
  }

  static Future<SessionGoogle> createAndInitialize() async {
    SessionGoogle session = SessionGoogle();
    await session.initialize();
    return session;
  }

  static Future<SessionGoogle> logout() async{
    const storage = FlutterSecureStorage();
    SessionGoogle session = SessionGoogle();
    await storage.delete(key: "username");
    await storage.delete(key: "url");
    await storage.delete(key: "token");
    _googleSignIn.disconnect();
    await session.initialize();
    return session;
  }
  static Future<SessionGoogle> googleLogin() async{
    SessionGoogle session = SessionGoogle();
    const storage = FlutterSecureStorage();
    GoogleSignInAccount? account = await _googleSignIn.signIn();
    bool isAuthorized = account != null;
    if (kIsWeb && account != null) {
      isAuthorized = _googleSignIn.canAccessScopes(scopes) as bool;
    }
    if (isAuthorized) {
      unawaited(_responseHttp(account!));
      await storage.write(key: "username", value: account.displayName);
      await storage.write(key: "url", value: account.photoUrl);
      await account.authentication.then((val)=>{
         storage.write(key: "token", value: val.accessToken)
      });
    }
    await session.initialize();
    return session;
  }

}
const List<String> scopes = <String>[
  'email',
  'profile',
];
GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
  '380369825003-pn4dcsi5l5hm3vtd7fn0ef11bjeqqtro.apps.googleusercontent.com',
  scopes: scopes,
);


//http통신 유저 Auth코드 가져오기
Future<void> _responseHttp(GoogleSignInAccount user) async {
  try {
    final http.Response response = await http.get(
      Uri.parse('$serverUri/login/google?code=$user'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedJson != null && decodedJson['data'] != null) {
        await writeToken(decodedJson['data']['accesstoken']);
      } else {

      }
    } else {
      print('response? : ${response.statusCode}');
    }
  } catch (e) {
    print('어떤 오류가 기다릴까? $e');
  }
}

Future<void> writeToken(String token) async {
  try {
    var dir = await getApplicationDocumentsDirectory();
    await File('${dir.path}/token.txt').writeAsString(token);
    print('토큰 저장 완료: $token');
  } catch (e) {
    print('토큰 저장 오류: $e');
  }
}