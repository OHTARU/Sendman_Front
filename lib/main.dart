import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/pages/camera_ui.dart';
import 'package:flutter_application_1/pages/stt.dart';
import 'package:flutter_application_1/pages/tts.dart';
import 'package:flutter_application_1/pages/tts_detail.dart';
import 'package:flutter_application_1/pages/tts_list.dart';
import 'package:flutter_application_1/src/get_token.dart';
import 'package:flutter_application_1/src/tts_post_dto.dart';
import 'package:flutter_application_1/widgets/custom_toast.dart';
import 'package:flutter_application_1/widgets/drawer.dart';
import 'package:flutter_application_1/src/session.dart';
import 'package:flutter_application_1/widgets/logo_screen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/widgets/app_bar.dart';
import 'package:flutter_application_1/src/sign_in_button/moblie.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
  List<TtsPost>? result;
  int textNum = 0;

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
    await _fetchPage();
    print('이제 1초면 이동');
    await Future.delayed(const Duration(seconds: 1));
    print('출력');
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
    await SessionGoogle.googleLogin().then((val) => {session = val});
    setState(() {
      sessionGoogle = session;
    });
  }

  Future<void> _fetchPage() async {
    String token = await GetToken().readToken();
    var url = Uri.parse("http://13.125.54.112:8080/list");

    Map<String, String> headers = {"Authorization": "Bearer $token"};
    var response = await http.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseList =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        result = TtsPostsList.fromJson(responseList['data']).posts;
        textNum = result!.length;
      });
    } else {
      Fluttertoast.showToast(
        msg: "세션이 만료되어 로그아웃 되었습니다!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 20.0,
      );
      sessionGoogle = await SessionGoogle.logout();
      setState(() {
        sessionGoogle;
      });
    }
  }

  Widget _buildBody(SessionGoogle user) {
    return Builder(
      builder: (BuildContext context) {
        if (user.username != "anonymous") {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 23),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: (textNum == 0)
                          ? Text("최근 대화가 없습니다!",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 20))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                (textNum == 0) ? 0 : textNum,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TtsDetail(
                                                  recognizedText:
                                                      result![index].text)));
                                    },
                                    child: Container(
                                      width: 160,
                                      height: 210,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Color(0xFFD5D5D5),
                                      ),
                                      color: Colors.grey,
                                      child: Text(result![index].text),
                                    ),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      tileColor: backTileColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              Text(title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.white)),
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

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      const msg = "'뒤로'버튼을 한 번 더 누르면 종료됩니다.";
      Fluttertoast.showToast(msg: msg);

      return Future.value(false);
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = CustomToast.showExitToast(); // context 제거
        if (shouldExit) {
          SystemNavigator.pop(); // 앱 즉시 종료
        }
      },
      child: Scaffold(
        appBar: (sessionGoogle.username != "anonymous")
            ? BaseAppBar(
                appBar: AppBar(),
                center: true,
              )
            : null,
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(sessionGoogle),
        ),
        drawer:
            (sessionGoogle.username != "anonymous") ? const BaseDrawer() : null,
        backgroundColor: Colors.white,
      ),
    );
  }
}
