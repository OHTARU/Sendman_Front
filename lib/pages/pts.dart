import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/camera_ui.dart';
import 'package:flutter_application_1/src/server_uri.dart';

class PhotoToText extends StatefulWidget {
  const PhotoToText({super.key});

  @override
  PhotoToTextState createState() => PhotoToTextState();
}

class PhotoToTextState extends State<PhotoToText> {
  final ImagePicker _picker = ImagePicker();
  String? _extractedText;

  Future<String?> _sendImageToOCR(File image) async {
    const String apiKey =
        'AIzaSyAtNXwq7_KtXWDop3ZV_WGryDfmcTTeZaM'; // 실제 API 키로 교체
    final Uri url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final Map<String, dynamic> requestBody = {
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "TEXT_DETECTION", "maxResults": 1}
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['responses'][0]['fullTextAnnotation']['text'];
    } else {
      return 'Error: ${response.statusCode} ${response.body}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo to Text OCR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  String? result = await _sendImageToOCR(File(image.path));
                  setState(() {
                    _extractedText = result;
                  });
                }
              },
              child: const Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraUI(
                      onPictureTaken: (File image) async {
                        return await _sendImageToOCR(image); // OCR 결과를 반환
                      },
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _extractedText = result as String?;
                  });
                }
              },
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 20),
            _extractedText != null
                ? Text(_extractedText!, textAlign: TextAlign.center)
                : const Text('No text extracted yet.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _extractedText != null
                  ? () => sendTextToServer(_extractedText!)
                  : null,
              child: const Text('Send Text to Server'),
            ),
          ],
        ),
      ),
    );
  }

// 호출 부분에서 에러 처리
  void someFunction(BuildContext context) async {
    try {
      await sendTextToServer("Your text");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text successfully sent to the server")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending text to server: $e")),
      );
    }
  }

// sendTextToServer 함수 수정
  Future<void> sendTextToServer(String text) async {
    final Uri url = Uri.parse("$serverUri/tts/save?text=$text");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to send text. Status code: ${response.statusCode}");
    }
  }
}


//AIzaSyAtNXwq7_KtXWDop3ZV_WGryDfmcTTeZaM