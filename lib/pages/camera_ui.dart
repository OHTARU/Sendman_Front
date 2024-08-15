import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/src/server_uri.dart';

import '../src/get_token.dart';

class CameraUI extends StatefulWidget {
  const CameraUI({super.key});

  @override
  State<CameraUI> createState() => _CameraUIState();
}

class _CameraUIState extends State<CameraUI> {
  late CameraController controller;
  late List<CameraDescription> _cameras;
  bool _isControllerInitialized = false;
  bool _isProcessing = false;
  XFile? _capturedXFile;
  String? _ocrResult;
  final ImagePicker _picker = ImagePicker();
  final GetToken _getToken = GetToken();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        controller = CameraController(
          _cameras[0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await controller.initialize();
        setState(() {
          _isControllerInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!_isControllerInitialized || !controller.value.isInitialized) {
      print('Camera is not initialized');
      return;
    }

    try {
      setState(() {
        _isProcessing = true; // 검은색 화면을 유지하기 위해 설정
      });

      _capturedXFile = await controller.takePicture();

      // 사진을 찍은 후 즉시 화면에 반영
      setState(() {});

      final File imageFile = File(_capturedXFile!.path);

      _ocrResult = await _sendImageToOCR(imageFile);

      if (_ocrResult != null) {
        await _sendTextToServer(_ocrResult!);  // OCR 결과를 백엔드로 전송
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사진 안에 있는 텍스트를 저장하였습니다!")),
        );
      }

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String?> _sendImageToOCR(File image) async {

    const String apiKey = 'AIzaSyAtNXwq7_KtXWDop3ZV_WGryDfmcTTeZaM';
    final Uri url =
    Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

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

  Future<void> _sendTextToServer(String text) async {
    String token = await _getToken.readToken();
    final Uri url = Uri.parse("$serverUri/tts/save?text=$text");  // 백엔드 서버의 API
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Text sent to server successfully");
    } else {
      throw Exception(
          "Failed to send text. Status code: ${response.statusCode}");
    }
  }

  void _retry() {
    setState(() {
      _capturedXFile = null;
      _ocrResult = null;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _capturedXFile = pickedFile;
          _isProcessing = true;
        });

        final File imageFile = File(pickedFile.path);

        _ocrResult = await _sendImageToOCR(imageFile);

        if (_ocrResult != null) {
          await _sendTextToServer(_ocrResult!);  // OCR 결과를 백엔드로 전송
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("사진 안에 있는 텍스트를 저장하였습니다!")),
          );
        }

        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewRatio =
        controller.value.previewSize!.height / controller.value.previewSize!.width;

    return Scaffold(
      body: Stack(
        children: [
          // 사진을 찍은 후, 그 사진을 배경으로 표시
          Positioned.fill(
            child: _capturedXFile == null
                ? Transform.scale(
              scale: previewRatio / deviceRatio,
              child: Center(
                child: AspectRatio(
                  aspectRatio: previewRatio,
                  child: CameraPreview(controller),
                ),
              ),
            )
                : Image.file(
              File(_capturedXFile!.path),
              fit: _capturedXFile!.path.contains('image_picker')
                  ? BoxFit.contain
                  : BoxFit.cover,
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7), // 검은색 화면 유지
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      '사진을 분석 중이에요',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isProcessing && _ocrResult != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            _ocrResult ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: GestureDetector(
                              onTap: _pickImageFromGallery,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: _retry,
                              child: Container(
                                width: 120,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: photoToTextCameraIconBackgroundColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isProcessing && _capturedXFile == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library_outlined,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: photoToTextCameraIconBackgroundColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
