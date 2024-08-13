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
  SessionGoogle sessionGoogle = SessionGoogle();
  @override
  //초기 데이터 로드, 컨트롤러 초기화
  void initState() {
    super.initState();
    initialization();
    sessionGoogle.initialize();
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



  Future<void> writeToken(String token) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/token.txt').writeAsString(token);
      print('토큰 저장 완료: $token');
    } catch (e) {
      print('토큰 저장 오류: $e');
    }
  }
  Future<void> _handleSignIn() async {
    SessionGoogle session = SessionGoogle();
    await SessionGoogle.googleLogin().then((val)=>{
      session = val
    });
    setState(() {
      sessionGoogle = session;
    });
  }
  Future<void>_handleLogout() async{
    SessionGoogle session = SessionGoogle();
    await SessionGoogle.logout().then((val)=>{
      session = val
    });
    setState(() {
      sessionGoogle = session;
    });

  }
  BaseDrawer _drawer(){
    setState(() {
      sessionGoogle.initialize();
    });
    return const BaseDrawer(drawer: Drawer());
  }
  Widget _buildBody(SessionGoogle user) {
    if (user.username != "anonymous") {
      return Column(
        children: <Widget>[
          TextButton(onPressed: (){}, child: const Text("stt"))
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
    setState(() {
      sessionGoogle.initialize();
    });
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        center: true,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(sessionGoogle),
      ),
      drawer: _drawer(),
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
