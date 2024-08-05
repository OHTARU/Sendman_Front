// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/server_uri.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PhotoToText extends StatefulWidget {
  const PhotoToText({super.key});

  @override
  PhotoToTextState createState() => PhotoToTextState();
}

class PhotoToTextState extends State<PhotoToText> {
  final ImagePicker _picker = ImagePicker();
  String? _extractedText;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _sendImageToOCR(File(image.path));
    }
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _sendImageToOCR(File(image.path));
    }
  }

  Future<void> _sendImageToOCR(File image) async {
    const String apiKey =
        'AIzaSyAtNXwq7_KtXWDop3ZV_WGryDfmcTTeZaM'; // Replace with your actual API key
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
      setState(() {
        _extractedText =
            jsonResponse['responses'][0]['fullTextAnnotation']['text'];
      });
    } else {
      setState(() {
        _extractedText = 'Error: ${response.statusCode} ${response.body}';
      });
    }
  }

  Future<void> sendTextToServer(String text) async {
    final Uri url = Uri.parse("$serverUri/tts/save?text=$text");

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Text successfully sent to the server")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Failed to send text. Status code: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending text to server: $e")));
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
              onPressed: _pickImage,
              child: const Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: _takePicture,
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
}
