import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/pages/camera_ui.dart';
import 'package:flutter_application_1/pages/stt.dart';
import 'package:flutter_application_1/pages/tts.dart';
import 'package:flutter_application_1/pages/tts_list.dart';
import 'package:flutter_application_1/widgets/widget_listtile.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "message": "안녕하세요? \n샌드맨이에요",
      "image": "assets/images/SendManIcon.png",
    },
    {
      "message": "여러분의 원활한 \n소통을 도와드릴게요",
      "image": "assets/images/SendManIcon.png",
    },
    {
      "message": "버튼을 터치해서 \n소통을 시작해보세요!",
      "image": "assets/images/SendManIcon.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                if (index == 2) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.5,
                                      color: Color.fromARGB(255, 255, 0, 0))),
                              child: buildListTile(context, Icons.mic, '음성',
                                  const SttPage(), listTile1),
                            ),
                            Divider(
                              color: Colors.black26,
                              height: 0.3,
                            ),
                            buildListTile(context, Icons.text_format, '텍스트',
                                null, listTile2),
                            Divider(
                              color: Colors.black26,
                              height: 1.2,
                            ),
                            buildListTile(
                                context, Icons.image, '사진', null, listTile3),
                            Divider(
                              color: Colors.black26,
                              height: 1.2,
                            ),
                            buildListTile(context, Icons.attach_file,
                                '사진텍스트 리스트', null, listTile4),
                          ],
                        ),
                        SizedBox(height: 40),
                        _buildSpeechBubble(_pages[index]["message"]!),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Image.asset(
                                _pages[index]["image"]!,
                                height: 100,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSpeechBubble(_pages[index]["message"]!),
                        SizedBox(height: 40),
                        Image.asset(
                          _pages[index]["image"]!,
                          height: 100,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentPage == index ? 12 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? mainThemeColor : Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SendManDemo()),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  '설명 건너뛰기',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String message) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
