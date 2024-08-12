import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionGoogle {
  String username = '';
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
}
