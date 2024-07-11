import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/app_bar.dart';
import 'package:flutter_application_1/page/init_screen.dart';
import 'package:flutter_application_1/page/page_tts.dart';
import 'package:flutter_application_1/page/stopwatch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';
import 'dart:async';
import 'page/page_record_storage.dart';
import 'package:flutter_application_1/src/server_uri.dart';

const List<String> scopes = <String>[
  'email',
  'profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '380369825003-pn4dcsi5l5hm3vtd7fn0ef11bjeqqtro.apps.googleusercontent.com',
  scopes: scopes,
);

void main() {
  runApp(
    const MaterialApp(
      title: '구글 로그',
      debugShowCheckedModeBanner: false,
      home: SendManDemo(),
    ),
  );
}

class SendManDemo extends StatefulWidget {
  const SendManDemo({super.key});

  @override
  State createState() => _SendManDemoState();
}

class _SendManDemoState extends State<SendManDemo> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';

  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    //    현재 flutter native splash 사용으로 사용 안함
    // Timer(const Duration(milliseconds: 1500), () {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => const InitScreen()));
    //   Timer(const Duration(milliseconds: 1500), () {
    //     Navigator.pop(context);
    //   });
    // });
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      if (mounted) {
        setState(() {
          _currentUser = account;
          _isAuthorized = isAuthorized;
        });
      }

      if (isAuthorized) {
        unawaited(_handleGetContact(account!));
      }
    });

    _googleSignIn.signInSilently();
  }

  //서버 연결 예외 처리 코드
  Future<void> _responseHttp(GoogleSignInAccount user) async {
    try {
      final http.Response response = await http.get(
          Uri.parse('$serverUri/login/google?code=${user.serverAuthCode}'));

      if (response.statusCode >= 200 || response.statusCode < 300) {
        var decodingJson =
            jsonDecode(utf8.decode(response.bodyBytes))['accesstoken'];
        if (kDebugMode) {
          print("response : $decodingJson");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('씻팔 서버 안열림');
      }
    }
  }

  void _initializeRecorder() async {
    try {
      await Permission.microphone.request();
    } catch (e) {
      if (kDebugMode) {
        print('권한 받는도중 오류');
      }
    }

    await Permission.storage.request();
    await _recorder!.openRecorder();
  }

  void _startRecording() async {
    try {
      await _recorder!.startRecorder(toFile: 'audio.aac');
      if (mounted) {
        setState(() {
          _isRecording = true;
        });
      }
      if (kDebugMode) {
        print("녹음시작");
      }
    } catch (e) {
      if (kDebugMode) {
        print("시작 안되노 씨발아: $e");
      }
    }
  }

  void _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      if (kDebugMode) {
        print("녹음 중지");
      }
    } catch (e) {
      if (kDebugMode) {
        print("녹음중지 에러씨발 $e");
      }
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    Future<GoogleSignInAuthentication> googleAuth = user.authentication;
    googleAuth.then((val) {
      _contactText = val.accessToken.toString();

      if (kDebugMode) {
        print(val.accessToken.toString());
      }
    }).catchError((err) {
      _contactText = err.toString();
    });
    //서버 연결 예외처리 전
    // final http.Response response = await http
    //     .get(Uri.parse('$serverUri/login/google?code=${user.serverAuthCode}'));

    // if (response.statusCode >= 200 || response.statusCode < 300) {
    //   var decodingJson =
    //       jsonDecode(utf8.decode(response.bodyBytes))['accesstoken'];
    //   if (kDebugMode) {
    //     print("response : $decodingJson");
    //   }
    // }

    _responseHttp(_currentUser!);
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // final GoogleSignInAuthentication googleSignInAuthentication = await _googleSignIn.currentUser!.authentication;
    } catch (error) {
      if (kDebugMode) {
        print('handleSingIn 에러 씨벌');
      }
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    if (mounted) {
      setState(() {
        _isAuthorized = isAuthorized;
      });
    }
    if (isAuthorized) {
      unawaited(_handleGetContact(_currentUser!));
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: GoogleUserCircleAvatar(identity: user),
                  title: Text(user.displayName ?? ''),
                  subtitle: Text(user.email),
                ),
                if (_isAuthorized) ...<Widget>[
                  Text(_contactText),
                ],
                if (!_isAuthorized) ...<Widget>[
                  const Text('읽기 접근 권한 필요'),
                  ElevatedButton(
                    onPressed: _handleAuthorizeScopes,
                    child: const Text('승인 요청123'),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _handleSignOut,
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecordStorage()));
                },
                child: const Text('텍스트파일저장 연습용'),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TextToSpeech()));
                },
                child: const Text('허은성 여기서 해'),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StopWatchPage()));
                  },
                  child: const Text('StopWatch페이지'))
            ],
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // fixedSize: const Size(0, 0),
                  elevation: 25,
                  shadowColor: Colors.black54,
                  backgroundColor: Colors.red,
                  iconColor: Colors.white,
                  surfaceTintColor: Colors.black,
                  foregroundColor: Colors.white54,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
                  alignment: const FractionalOffset(1, 1),

                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(100),
                  // )
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 40,
                ),
              ),
            ],
          ),
          Container(
            color: footerMainColor2,
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              '바닥',
              textAlign: TextAlign.center,
              style: TextStyle(color: appBarTextColor, fontSize: 16),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('로그인 안됐음'),
                buildSignInButton(onPressed: _handleSignIn),
              ],
            ),
          ),
          Container(
            color: footerMainColor,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? '녹음 중지' : '녹음 시작'),
            ),
          ),
          Container(
            color: footerMainColor2,
            width: double.infinity,
            padding: const EdgeInsets.all(17.0),
            child: const Text(
              'Footer',
              textAlign: TextAlign.center,
              style: TextStyle(color: appBarTextColor, fontSize: 16),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: '메인 앱바',
        center: true,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
