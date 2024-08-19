import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/main.dart';
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

    if (kIsWeb) {
      isAuthorized = await googleSignIn.canAccessScopes(scopes);
    }
    if (isAuthorized) {
      await _getAccessToken(account);
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
                SendManDemo(state: isAuthorized, account: account),
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
}// 스플래시 스크린 현재 사용 X

/* 스플래시 스크린 연결 메인 페이지
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_application_1/page/swatch.dart';
import 'package:flutter_application_1/page/app_bar.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/page/page_tts.dart';
import 'package:flutter_application_1/src/server_uri.dart';
import 'package:flutter_application_1/page/page_record_storage.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_1/page/splash_screen.dart';
import 'package:flutter_application_1/page/photo_to_text.dart';

const List<String> scopes = <String>[
  'email',
  'profile',
];

GoogleSignIn googleSignIn = GoogleSignIn(
  clientId:
      '380369825003-pn4dcsi5l5hm3vtd7fn0ef11bjeqqtro.apps.googleusercontent.com',
  scopes: scopes,
);

void main() {
  runApp(
    const MaterialApp(
      home: SplashScreen(),
    ),
  );
}

class SendManDemo extends StatefulWidget {
  final bool state;
  final GoogleSignInAccount? account;
  const SendManDemo({super.key, required this.state, required this.account});

  @override
  State<SendManDemo> createState() => _SendManDemoState();
}

class _SendManDemoState extends State<SendManDemo> {
  late bool state;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  // ignore: unused_field
  String _tokenText = '';
  String accessTokenBearer = '';
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  int audioNum = 0;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final bool _isMinutes = true;
  late final File file;

  @override
  void initState() {
    super.initState();
    state = widget.state;
    _currentUser = widget.account;
    _isAuthorized = state;
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
    print('이닛');
    print(_isAuthorized);
  }

  Future<void> _responseHttp(GoogleSignInAccount user) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$serverUri/login/google?code=${user.serverAuthCode}'),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedJson != null && decodedJson['data'] != null) {
          String accessToken = decodedJson['data']['accesstoken'];
          print(
              "response : ${response.statusCode} | decodingJson : $accessToken");
          accessTokenBearer = accessToken;
        } else {
          print("Error: 'data' key not found in the JSON response.");
        }
      } else {
        print('response? : ${response.statusCode}');
      }
    } catch (e) {
      print('서버 오류?');
      print('어떤 오류가 기다릴까? $e');
    }
  }

  void _initializeRecorder() async {
    try {
      await Permission.microphone.request();
      await Permission.storage.request();
      await _recorder!.openRecorder();
    } catch (e) {
      if (kDebugMode) {
        print('권한 요청 중 오류: $e');
      }
    }
  }

  Future<void> uploadFile(String filePath) async {
    try {
      var uri = Uri.parse('$serverUri/stt/save');
      Map<String, String> headers = {
        "Authorization": "Bearer ${accessTokenBearer.toString()}"
      };
      print(accessTokenBearer.toString());
      var request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      var response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('파일 전송 성공');
      } else {
        print('파일 전송 실패, 응답 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<String> _getFilePath() async {
    final directory = await getExternalStorageDirectory();
    String fileName = DateTime.now()
        .toString()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll(' ', '_')
        .substring(0, 15);
    String returnFilePath = '${directory!.path}/$fileName.aac';

    File file = File(returnFilePath);
    if (await file.exists()) {
      String seconds = DateTime.now().second.toString().padLeft(2, '0');
      fileName = '${fileName}_$seconds';
      returnFilePath = '${directory.path}/$fileName.aac';
    }
    return returnFilePath;
  }

  void _startRecording() async {
    try {
      final filePath = await _getFilePath();
      await _recorder!.startRecorder(toFile: filePath);
      if (mounted) {
        setState(() {
          _isRecording = true;
        });
      }
      print("녹음 시작");
      print(filePath.toString());
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    } catch (e) {
      print("녹음 시작 오류: $e");
    }
  }

  void _stopRecording() async {
    try {
      final filePath = await _recorder!.stopRecorder();

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      print("녹음 중지");
      print("저장된 파일 경로: \n $filePath");

      await uploadFile(filePath!);
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    } catch (e) {
      if (kDebugMode) {
        print("녹음 중지 오류: $e");
      }
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  Future<void> _getAccessToken(GoogleSignInAccount user) async {
    try {
      final GoogleSignInAuthentication googleAuth = await user.authentication;
      _tokenText = googleAuth.accessToken.toString();
      print('_getAccessToken() 액세스 토큰 : ${googleAuth.accessToken.toString()}');
    } catch (e) {
      _tokenText = e.toString();
    }

    _responseHttp(_currentUser!);
  }

  Future<void> _handleSignIn() async {
    try {
      await googleSignIn.signIn();
      print('로그인중');
    } catch (error) {
      if (kDebugMode) {
        print('로그인 오류$error');
      }
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await googleSignIn.requestScopes(scopes);
    if (mounted) {
      setState(() {
        print('셋 스테이트');
        _isAuthorized = isAuthorized;
      });
    }
    if (isAuthorized) {
      unawaited(_getAccessToken(_currentUser!));
    }
  }

  Future<void> _handleSignOut() => googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: GoogleUserCircleAvatar(identity: user),
                  title: Text(user.displayName ?? ''),
                  subtitle: Text(user.email),
                ),
                if (_isAuthorized) ...<Widget>[],
                if (!_isAuthorized) ...<Widget>[
                  const Text('읽기 접근 권한 필요'),
                  ElevatedButton(
                    onPressed: _handleAuthorizeScopes,
                    child: const Text('승인 요청'),
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
          Swatch(
            stopWatchTimer: _stopWatchTimer,
            isMinutes: _isMinutes,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordStorage(),
                    ),
                  );
                },
                child: const Text('텍스트 파일 저장 연습용'),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhotoToText(),
                    ),
                  );
                },
                child: const Text('PTT'),
              )
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
                      builder: (context) => const TextToSpeech(),
                    ),
                  );
                },
                child: const Text('텍스트 음성 변환'),
              ),
            ],
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 25,
                  shadowColor: Colors.black54,
                  backgroundColor: Colors.red,
                  iconColor: Colors.white,
                  surfaceTintColor: Colors.black,
                  foregroundColor: Colors.white54,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
                  alignment: const FractionalOffset(1, 1),
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 40,
                ),
              ),
            ],
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
                const Text('로그인 안됨'),
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
      bottomNavigationBar: Container(
        color: footerMainColor2,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '바닥',
          textAlign: TextAlign.center,
          style: TextStyle(color: appBarTextColor, fontSize: 16),
        ),
      ),
    );
  }
}
