import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';
import 'dart:async';
import 'file_app.dart';

const List<String> scopes = <String>[
  'email',
  'profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

void main() {
  runApp(
    const MaterialApp(
      title: '구글 로그인',
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';

  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
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

  void _initializeRecorder() async {
    await Permission.microphone.request();
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
    final http.Response response = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people/me/connections'
            '?requestMask.includeField=person.names'),
        headers: await user.authHeaders);
    if (response.statusCode != 200) {
      if (mounted) {
        setState(() {
          _contactText = 'People API gave a ${response.statusCode} '
              'response. Check logs for details.';
        });
      }
      if (kDebugMode) {
        print('People API ${response.statusCode} response: ${response.body}');
      }
      return;
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const FileApp()));
                },
                child: const Text('텍스트파일저장 연습용'),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // fixedSize: const Size(0, 0),
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              surfaceTintColor: Colors.black,
              foregroundColor: Colors.white54,
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
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
