import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart'; // Clipboard 관련 클래스 포함

class TtsDetail extends StatefulWidget {
  final String recognizedText; // 다른 파일에서 전달받은 텍스트

  const TtsDetail({super.key, required this.recognizedText});

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
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    // TTS 재생 완료 시 상태를 업데이트
    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    // TTS 취소 시 상태를 업데이트
    flutterTts.setCancelHandler(() {
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
        // 텍스트가 비어있을 경우 경고 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('입력된 텍스트가 없습니다.')),
        );
      }
    } catch (e) {
      // 오류 발생 시 콘솔에 출력하고 사용자에게 알림
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
      if (result == 1) setState(() => ttsState = TtsState.stopped);
    } catch (e) {
      // 오류 발생 시 콘솔에 출력하고 사용자에게 알림
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

  // 리소스 해제를 위한 dispose 메서드
  @override
  void dispose() {
    flutterTts.stop(); // TTS 리소스를 해제하여 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: _copyToClipboard, // 복사 기능 연결
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 인식된 텍스트가 있으면 텍스트를 표시
            if (widget.recognizedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 배경색
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.recognizedText,
                  style: const TextStyle(
                    fontSize: 18, // 텍스트 크기
                    color: Colors.black87, // 텍스트 색상
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            // 재생 및 정지 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // 둥근 모서리
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: isPlaying ? Colors.red : Colors.blue,
              ),
              onPressed: widget.recognizedText.isNotEmpty
                  ? (isPlaying ? _stop : _speak) // 상태에 따라 재생 또는 정지
                  : null,
              child: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow, // 상태에 따른 아이콘 변경
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
