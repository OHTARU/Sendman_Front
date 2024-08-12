import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SessionGoogle {
  late String username = '';
  ImageProvider url = const AssetImage('assets/images/ExampleLogo.png');
  late String token;

  SessionGoogle() {
    _read();
  }

  void _read() async {
    const storage = FlutterSecureStorage();
    String? username = await storage.read(key: "username");
    String? urlString = await storage.read(key: "url"); // URL 문자열을 저장
    String? token = await storage.read(key: "token");

    if (username != null && token != null) {
      this.username = username;
      this.token = token;
    } else {
      this.username = "anonymous";
      this.token = "anonymous";
    }
    url = urlString != null
        ? NetworkImage(urlString)
        : const NetworkImage(''); // NetworkImage를 사용
  }

  static save(GoogleSignInAccount user, SessionGoogle instance) async {
    const storage = FlutterSecureStorage();
    GoogleSignInAuthentication auth = await user.authentication;
    await storage.write(key: "username", value: user.displayName);
    await storage.write(key: "url", value: user.photoUrl);
    await storage.write(key: "token", value: auth.accessToken);

    instance.token = auth.accessToken!;
    instance.username = user.displayName!;
    instance.url = NetworkImage(user.photoUrl!); // NetworkImage 객체 생성
  }
}
