import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui'; // 블러 처리를 위해 필요
import 'package:flutter_application_1/colors/colors.dart';

class CameraUI extends StatefulWidget {
  final Future<String?> Function(File image) onPictureTaken;

  const CameraUI({super.key, required this.onPictureTaken});

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
  final ImagePicker _picker = ImagePicker(); // 갤러리에서 이미지 선택을 위해 추가

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
        await controller.setZoomLevel(1.0);

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
        _isProcessing = true;
      });

      // 사진을 찍고 UI를 즉시 업데이트
      _capturedXFile = await controller.takePicture();

      // UI를 즉시 갱신하여 사진이 찍힌 상태를 표시
      setState(() {});

      // 사진을 파일로 변환하여 OCR 처리
      final File imageFile = File(_capturedXFile!.path);

      // OCR 결과를 받아오기
      _ocrResult = await widget.onPictureTaken(imageFile);

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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        setState(() {
          _capturedXFile = pickedFile;
          _isProcessing = true;
        });

        // OCR 결과를 받아오기
        _ocrResult = await widget.onPictureTaken(imageFile);

        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  void _retry() {
    setState(() {
      _capturedXFile = null;
      _ocrResult = null;
    });
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
    final previewRatio = controller.value.previewSize!.height /
        controller.value.previewSize!.width;

    return Stack(
      children: [
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
                  fit: BoxFit.cover,
                ),
        ),
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Material(
                    type: MaterialType.transparency,
                    child: Text(
                      '사진을 분석 중이에요',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!_isProcessing && _ocrResult != null)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _ocrResult ?? '', // null인 경우 빈 문자열로 대체
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _retry,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 10,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.refresh,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 10,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 10,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
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
    );
  }
}
