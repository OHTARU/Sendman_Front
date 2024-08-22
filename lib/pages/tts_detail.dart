import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/widgets/drawer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart'; // Clipboard 관련 클래스 포함

class TtsDetail extends StatefulWidget {
  final String recognizedText; // 다른 파일에서 전달받은 텍스트
  final String date;

  const TtsDetail(
      {super.key, required this.recognizedText, required this.date});

  @override
  TtsDetailState createState() => TtsDetailState();
}

enum TtsState { playing, stopped }

class TtsDetailState extends State<TtsDetail> {
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  // TTS 초기화 및 핸들러 설정
  void initTts() {
    flutterTts = FlutterTts();

    // TTS 재생 시작 시 상태를 업데이트
    flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    // TTS 재생 완료 시 상태를 업데이트
    flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    // TTS 취소 시 상태를 업데이트
    flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  // TTS 음성 재생 함수
  Future<void> _speak() async {
    try {
      if (widget.recognizedText.isNotEmpty) {
        // 텍스트가 있을 경우 TTS로 읽기 시작
        await flutterTts.speak(widget.recognizedText);
      } else {
        if (!mounted) return; // 위젯이 마운트되었는지 확인
        // 텍스트가 비어있을 경우 경고 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('텍스트가 없습니다.')),
        );
      }
    } catch (e) {
      // 오류 발생 시 콘솔에 출력하고 사용자에게 알림
      if (!mounted) return; // 위젯이 마운트되었는지 확인
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음성 재생에 실패했습니다.')),
      );
    }
  }

  // TTS 음성 정지 함수
  Future<void> _stop() async {
    try {
      var result = await flutterTts.stop();
      if (result == 1) {
        if (!mounted) return; // 위젯이 마운트되었는지 확인
        setState(() => ttsState = TtsState.stopped);
      }
    } catch (e) {
      // 오류 발생 시 콘솔에 출력하고 사용자에게 알림
      if (!mounted) return; // 위젯이 마운트되었는지 확인
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음성 정지에 실패했습니다.')),
      );
    }
  }

  // 텍스트를 클립보드에 복사하는 함수
  void _copyToClipboard() {
    if (widget.recognizedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: widget.recognizedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('클립보드에 복사되었습니다')),
      );
    }
  }

  void _backpage() {
    Navigator.pop(context);
  }

  // 리소스 해제를 위한 dispose 메서드
  @override
  void dispose() {
    flutterTts.stop(); // TTS 리소스를 해제하여 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: scaffoldBackground,
            body: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 35,
                              ),
                              onPressed: _backpage,
                            ),
                          ),
                          Text(
                            '인식결과',
                            style: TextStyle(fontSize: 30),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.content_copy,
                                size: 35,
                              ),
                              onPressed: _copyToClipboard,
                              tooltip: '클립보드에 복사',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 인식된 텍스트가 있으면 텍스트를 표시하고, 없으면 '텍스트 추출 오류' 표시
                    Container(
                      width: 350,
                      height: 500,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white, // 배경색
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // 가로 방향 스크롤 활성화
                        child: Container(
                          width: 350, // 중요: 가로 스크롤 내부 컨테이너의 너비 지정
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical, // 세로 방향 스크롤 활성화
                            child: Text(
                              widget.recognizedText.isNotEmpty
                                  ? widget.recognizedText
                                  : '목소리 녹음이 되지 않았습니다',
                              style: TextStyle(
                                fontSize: 24, // 텍스트 크기
                                color: widget.recognizedText.isNotEmpty
                                    ? Colors.black87
                                    : Colors.grey, // 색상
                                fontWeight: FontWeight.w400, // 폰트 두께
                                letterSpacing: 0.5,
                                height: 1.4,
                              ),

                              textAlign: TextAlign.center, // 텍스트 중앙 정렬
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(widget.date,
                        style: TextStyle(fontSize: 30, color: Colors.grey)),
                    // 재생 및 정지 버튼
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 18),
                        alignment: const FractionalOffset(1, 1),
                        backgroundColor: isPlaying ? Colors.grey : Colors.red,
                      ),
                      onPressed: widget.recognizedText.isNotEmpty
                          ? (isPlaying ? _stop : _speak) // 상태에 따라 재생 또는 정지
                          : null,
                      child: Icon(
                        isPlaying
                            ? Icons.stop
                            : Icons.play_arrow, // 상태에 따른 아이콘 변경
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            drawer: const BaseDrawer()));
  }
}
