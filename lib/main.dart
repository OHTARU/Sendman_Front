import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/pages/camera_ui.dart';
import 'package:flutter_application_1/pages/stt.dart';
// import 'package:flutter_application_1/pages/stt_list.dart';
import 'package:flutter_application_1/pages/tts.dart';
import 'package:flutter_application_1/pages/tts_detail.dart';
import 'package:flutter_application_1/pages/tts_list.dart';
import 'package:flutter_application_1/widgets/drawer.dart';
import 'package:flutter_application_1/src/session.dart';
import 'package:flutter_application_1/widgets/logo_screen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/widgets/app_bar.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true,
  );
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
  }

  void initialization() async {
    await sessionGoogle.initialize();
    setState(() {
      sessionGoogle;
    });
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
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
    await SessionGoogle.googleLogin().then((val) => {session = val});
    setState(() {
      sessionGoogle = session;
    });
  }

  Widget _buildBody(SessionGoogle user) {
    return Builder(
      builder: (BuildContext context) {
        if (user.username != "anonymous") {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 0, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('최근 대화',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20)),
                    const SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              width: 140,
                              height: 210,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildListTile(
                      context, Icons.mic, '음성', const SttPage(), listTile1),
                  buildListTile(context, Icons.text_format, '텍스트',
                      const TextToSpeech(), listTile2),
                  buildListTile(
                      context, Icons.image, '사진', const CameraUI(), listTile3),
                  buildListTile(context, Icons.attach_file, '사진텍스트 리스트',
                      const TtsList(), listTile4),
                  buildListTile(context, Icons.abc, '디테일',
                      const TtsDetail(recognizedText: ''), listTile5)
                ],
              ),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildLogoScreen(),
              buildSignInButton(onPressed: _handleSignIn)
            ],
          );
        }
      },
    );
  }

  ListTile buildListTile(BuildContext context, IconData icon, String title,
      Widget destinationPage, Color backTileColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      tileColor: backTileColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Text(title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20)),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destinationPage));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        center: true,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(sessionGoogle),
      ),
      drawer: const BaseDrawer(),
      backgroundColor: Colors.white,
    );
  }
}
