import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "온보딩1",
      "message": "안녕하세요? 샌드맨이에요",
      "image": "assets/images/SendManIcon.png",
    },
    {
      "title": "온보딩2",
      "message": "여러분의 원활한 소통을 도와드릴게요",
      "image": "assets/images/SendManIcon.png",
    },
    {
      "title": "스플래쉬",
      "message": "버튼을 터치해서 소통을 시작해보세요!",
      "image": "assets/images/SendManIcon.png",
      "buttons": [
        {"icon": Icons.mic, "label": "음성"},
        {"icon": Icons.text_fields, "label": "텍스트"},
        {"icon": Icons.image, "label": "사진"},
        {"icon": Icons.attachment, "label": "사진텍스트 리스트"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(
            visible: _currentPage == 0,
            child: buildPage(context, 0),
          ),
          Visibility(
            visible: _currentPage == 1,
            child: buildPage(context, 1),
          ),
          Visibility(
            visible: _currentPage == 2,
            child: buildPageWithButtons(context, 2),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SendManDemo()),
                );
              },
              child: Text(
                '설명 건너뛰기',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _currentPage < _pages.length - 1
                    ? Icons.arrow_forward
                    : Icons.check,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  if (_currentPage < _pages.length - 1) {
                    _currentPage++;
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SendManDemo()),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _pages[index]["title"]!,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _pages[index]["message"]!,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          Image.asset(
            _pages[index]["image"]!,
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget buildPageWithButtons(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _pages[index]["title"]!,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: _pages[index]["buttons"].map<Widget>((button) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    //아 뭐 넣어야하냐 할거 개많네 진짜
                  },
                  icon: Icon(button["icon"]),
                  label: Text(button["label"]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _pages[index]["message"]!,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          Image.asset(
            _pages[index]["image"]!,
            height: 100,
          ),
        ],
      ),
    );
  }
}
