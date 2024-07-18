import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/page/app_bar.dart';
import 'package:flutter_application_1/page/page_record_storage.dart';
import 'package:flutter_application_1/page/page_tts.dart';
import 'package:flutter_application_1/page/swatch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';
import 'dart:async';
import 'package:flutter_application_1/src/server_uri.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:path_provider/path_provider.dart';
//import 'dart:io';

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
  // ignore: unused_field
  String _tokenText = '';

  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final bool _isMinutes = true;
  late final File file;
  @override
  //초기 데이터 로드, 컨트롤러 초기화
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = _googleSignIn.canAccessScopes(scopes) as bool;
      }

      if (mounted) {
        setState(() {
          _currentUser = account;
          _isAuthorized = isAuthorized;
        });
      }

      if (isAuthorized) {
        unawaited(_getAccessToken(account!));
      }
    });

    _googleSignIn.signInSilently();
  }

  //http통신 유저 Auth코드 가져오기
  Future<void> _responseHttp(GoogleSignInAccount user) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$serverUri/login/google?code=${user.serverAuthCode}'),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var decodingJson =
            jsonDecode(utf8.decode(response.bodyBytes))['accesstoken'];
        if (kDebugMode) {
          print("response : $decodingJson");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('서버 오류');
        print(e);
      }
    }
  }

  //녹음 초기화 마이크, 저장소 등 권한 요청
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

  //녹음파일 저장 경로
  Future<String> _getFilePath() async {
    final directory = await getExternalStorageDirectory();
    int audioNum = 0;
    //음성 녹음파일 audioNum +1,

    return '${directory!.path}/audio$audioNum.aac';
  }

  //녹음 시작
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

  //녹움 즁지
  void _stopRecording() async {
    try {
      final filePath = await _recorder!.stopRecorder();

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      if (kDebugMode) {
        print("녹음 중지");
        print("저장된 파일 경로: \n $filePath");
      }
      // file = File(filePath.toString());
      // print(file.toString());
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

  // 구글 AccessToken toString으로 가져옴
  Future<void> _getAccessToken(GoogleSignInAccount user) async {
    try {
      final GoogleSignInAuthentication googleAuth = await user.authentication;
      _tokenText = googleAuth.accessToken.toString();

      if (kDebugMode) {
        print(googleAuth.accessToken.toString());
      }
    } catch (err) {
      _tokenText = err.toString();
    }

    _responseHttp(_currentUser!);
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print('로그인 오류');
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
      unawaited(_getAccessToken(_currentUser!));
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
            flex: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: GoogleUserCircleAvatar(identity: user),
                  title: Text(user.displayName ?? ''),
                  subtitle: Text(user.email),
                ),
                if (_isAuthorized) ...<Widget>[
                  // 액세스 토큰
                  // Text(_contactText),
                ],
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
