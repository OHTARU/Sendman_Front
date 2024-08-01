import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/main.dart'; // main.dart 파일을 임포트하여 googleSignIn 변수를 가져옴
import 'package:flutter_application_1/src/server_uri.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    GoogleSignInAccount? account =
        await googleSignIn.signInSilently(); // googleSignIn 변수를 사용
    bool isAuthorized = account != null;

    if (kIsWeb && account != null) {
      isAuthorized = await googleSignIn.canAccessScopes(scopes);
    }
    if (isAuthorized) {
      await _getAccessToken(account!);
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SendManDemo(
              state: isAuthorized,
              account: account,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                SendManDemo(state: isAuthorized, account: account!),
          ),
        );
      }
    }
  }

  Future<void> _getAccessToken(GoogleSignInAccount user) async {
    final GoogleSignInAuthentication googleAuth = await user.authentication;
    String accessToken = googleAuth.accessToken.toString();
    print('액세스 토큰: $accessToken');

    final http.Response response = await http.get(
      Uri.parse('$serverUri/login/google?code=${user.serverAuthCode}'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedJson != null && decodedJson['data'] != null) {
        String accessToken = decodedJson['data']['accesstoken'];
        //로컬스토리지 넣는 로직 넣을것
        print(
            "response : ${response.statusCode} | decodingJson : $accessToken");
      } else {
        print('response? : ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: footerMainColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/InitLogo.png',
                  width: 200,
                ),
                const CircularProgressIndicator(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
