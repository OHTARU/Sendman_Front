import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/camera_ui.dart';
import 'package:flutter_application_1/pages/tts.dart';
import 'package:flutter_application_1/pages/stt_list.dart';
import 'package:flutter_application_1/pages/stt.dart';
import 'package:flutter_application_1/pages/tts_list.dart';
import 'package:flutter_application_1/src/session.dart';

import '../main.dart';

class BaseDrawer extends StatelessWidget {
  const BaseDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionGoogle>(
      future: SessionGoogle.createAndInitialize(), // SessionGoogle 초기화를 기다림
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          SessionGoogle sessionGoogle = snapshot.data!;
          return buildDrawer(sessionGoogle, context);
        } else {
          return const CircularProgressIndicator(); // 로딩 중 표시
        }
      },
    );
  }

  Drawer buildDrawer(SessionGoogle sessionGoogle, BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CloseButton(),
                        ],
                      ),
                      CircleAvatar(backgroundImage: sessionGoogle.url),
                      const SizedBox(height: 10),
                      Text(sessionGoogle.username,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                buildListTile(
                    context, Icons.text_format, "음성 - 글자", const SttPage()),
                buildListTile(
                    context, Icons.mic, "글자 - 음성", const TextToSpeech()),
                buildListTile(
                    context, Icons.image, "사진 - 글자", const CameraUI()),
                buildListTile(
                    context, Icons.attach_file, "음성 텍스트 보기", const SttList()),
                buildListTile(
                    context, Icons.attach_file, "사진 텍스트 보기", const TtsList()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: buildTextButton(
                    context, sessionGoogle.username == "anonymous"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextButton buildTextButton(BuildContext context, bool isUser) {
    String data;
    isUser ? (data = "로그인") : (data = "로그아웃");
    return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 16, 38, 104),
        ),
        onPressed: () {
          isUser ? (SessionGoogle.googleLogin()) : (SessionGoogle.logout());
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SendManDemo()),
              (route) => false);
        },
        child: Text(data,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)));
  }

  ListTile buildListTile(BuildContext context, IconData icon, String title,
      Widget destinationPage) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          Icon(icon),
          const SizedBox(width: 20),
          Text(title,
              textAlign: TextAlign.start,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
        ],
      ),
      onTap: () {
        Scaffold.of(context).openEndDrawer();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destinationPage));
      },
    );
  }
}
