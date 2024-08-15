import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/swatch.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:http/http.dart' as http;

import '../src/server_uri.dart';
import '../src/session.dart';
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';

class SttPage extends StatefulWidget {
  const SttPage({super.key});
  @override
  State createState() => _SttPage();
}

class _SttPage extends State<SttPage> {
  SessionGoogle sessionGoogle = SessionGoogle();
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final bool _isMinutes = true;
  late final File file;
  String result = "";
  bool isSend = false;
  int audioNum = 0;
  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
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
      print('읽어온 토큰 sttPage readToken() : $file');
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
      setState(() {
        isSend = true;
      });
      // 서버 업로드 URI
      var uri = Uri.parse('$serverUri/stt/save');
      Map<String, String> headers = {
        "Authorization": "Bearer ${accessTokenBearer.toString()}"
      };
      print('서버 업로드 URI ${accessTokenBearer.toString()}');
      //맵으로 header추가
      var request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath(
        'file', // 서버에서 파라미터명 확인
        filePath,
      ));

      // 요청
      var response = await request.send();

      // 응답
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var res = jsonDecode(utf8.decode(await response.stream.single));

        setState(() {
          isSend = false;
          result = res['data']['result'].toString();
        });
        print(result);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("녹음 한 내용을 저장하였습니다.")),
        );
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
          result = "";
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
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

      print("녹음 중지");
      print("저장된 파일 경로: \n $filePath");

      //업로드 파일
      await uploadFile(filePath!);
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      // file = File(filePath.toString());
      // print(file.toString());
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

  Widget _buildBody(SessionGoogle user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            Text(
              _isRecording ? (isSend ? "분석 중 입니다!" : "녹음 중") : '음성 녹음을 시작해주세요',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            )
          ],
        ),
        Swatch(
          stopWatchTimer: _stopWatchTimer,
          isMinutes: _isMinutes,
        ),
        Text((result != "") ? result : ""),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                  alignment: const FractionalOffset(1, 1),
                ),
                onPressed: _isRecording
                    ? (isSend ? null : _stopRecording)
                    : _startRecording,
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
      drawer: const BaseDrawer(),
    );
  }
}
