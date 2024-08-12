import 'dart:async';
import 'dart:convert';
//import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/pages/drawer.dart';
import 'package:flutter_application_1/src/session.dart';
// import 'package:flutter_application_1/pages/photo_to_text.dart';
// import 'package:flutter_application_1/pages/stt_list.dart';
// import 'package:flutter_application_1/pages/tts_list.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_application_1/pages/swatch.dart';
import 'package:flutter_application_1/pages/app_bar.dart';
// import 'package:flutter_application_1/colors/colors.dart';
// import 'package:flutter_application_1/pages/page_tts.dart';
import 'package:flutter_application_1/src/server_uri.dart';
import 'package:flutter_application_1/pages/token_storage.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

const List<String> scopes = <String>[
  'email',
  'profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '380369825003-pn4dcsi5l5hm3vtd7fn0ef11bjeqqtro.apps.googleusercontent.com',
  scopes: scopes,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true,
  );
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    const MaterialApp(
      title: '이게 왜 진짜 앱?',
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
  SessionGoogle sessionGoogle = SessionGoogle();
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
  //초기 데이터 로드, 컨트롤러 초기화
  void initState() {
    super.initState();
    initialization();
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

  void initialization() async {
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  //http통신 유저 Auth코드 가져오기
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
          await writeToken(accessToken);
        } else {
          print("Error: 'data' key not found in the JSON response.");
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

  Future<String> readToken() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File('${dir.path}/token.txt').readAsString();
      print('읽어온 토큰 : $file');
      return file;
    } catch (e) {
      print('토큰 읽기 실패하심~ㅋㅋ $e');
      return '';
    }
  }

  //파일 업로드 함수
  Future<void> uploadFile(String filePath) async {
    try {
      var accessTokenBearer = await readToken();
      if (accessTokenBearer.isEmpty) {
        print('노 토큰');
        return;
      }

      // 서버 업로드 URI
      var uri = Uri.parse('$serverUri/stt/save');
      Map<String, String> headers = {
        "Authorization": "Bearer ${accessTokenBearer.toString()}"
      };
      print(accessTokenBearer.toString());
      //맵으로 header추가
      var request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath(
        'file', // 서버에서 파라미터명 확인
        filePath,
        // contentType: MediaType('audio', 'aac'),
      ));

      // 요청
      var response = await request.send();

      // 응답
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('파일 전송 성공');
      } else {
        print('파일 전송 실패, 응답 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  //녹음파일 저장 경로
  Future<String> _getFilePath() async {
    final directory = await getExternalStorageDirectory();

    String fileName = DateTime.now()
        .toString()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll(' ', '_')
        .substring(0, 15);
    String returnFilePath = '${directory!.path}/$fileName.aac';

//파일 기본 형식 년월일시분 => if 같은 년월일시분 존재시 초 추가
    File file = File(returnFilePath);
    if (await file.exists()) {
      String seconds = DateTime.now().second.toString().padLeft(2, '0');
      fileName = '${fileName}_$seconds';
      returnFilePath = '${directory.path}/$fileName.aac';
    }
    //저장 파일 이름 날짜로 변경
    //final formatter = DateFormat('yyyyMMdd_HHmmss');
    //final String timestamp = formatter.format(DateTime.now());
    //returnPath = '${directory!.path}/$timestamp.aac';

    // bool fileExists;
    // do {
    //   fileExists = await File(returnPath).exists();
    //   //음성 녹음파일 audioNum +1,
    //   if (fileExists) {
    //     audioNum++;
    //   }
    // } while (fileExists);

    return returnFilePath;
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
      print("녹음 중지");
      print("저장된 파일 경로: \n $filePath");

      //업로드 파일
      await uploadFile(filePath!);

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
      print('_getAccessToken() 액세스 토큰 : ${googleAuth.accessToken.toString()}');
    } catch (e) {
      _tokenText = e.toString();
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

  Widget _buildBody(GoogleSignInAccount? user) {
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
          Column(
            children: [
              Text(
                _isRecording ? '녹음 중' : '음성 녹음을 시작해주세요',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              )
            ],
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
                      builder: (context) => const TokenStorage(),
                    ),
                  );
                },
                child: const Text('텍스트 파일 저장 연습용'),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 25,
                    shadowColor: Colors.black54,
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    surfaceTintColor: Colors.black,
                    foregroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 18),
                    alignment: const FractionalOffset(1, 1),
                  ),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 40,
                  ),
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
          // Container(
          //   color: footerMainColor,
          //   padding: const EdgeInsets.all(16),
          //   child: ElevatedButton(
          //     onPressed: _isRecording ? _stopRecording : _startRecording,
          //     child: Text(_isRecording ? '녹음 중지' : '녹음 시작'),
          //   ),
          // ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        center: true,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(user),
      ),
      drawer: const BaseDrawer(drawer: Drawer()),
      // bottomNavigationBar: Container(
      //   color: footerMainColor2,
      //   width: double.infinity,
      //   padding: const EdgeInsets.all(16.0),
      //   child: const Text(
      //     '바닥',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(color: appBarTextColor, fontSize: 16),
      //   ),
      // ),
    );
  }
}
