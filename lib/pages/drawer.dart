import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/page_tts.dart';
import 'package:flutter_application_1/pages/photo_to_text.dart';
import 'package:flutter_application_1/pages/stt_list.dart';
import 'package:flutter_application_1/pages/tts_list.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BaseDrawer extends StatelessWidget {
  const BaseDrawer({super.key, required this.drawer, required this.user});
  final GoogleSignInAccount? user;
  final Drawer drawer;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if (user != null) {
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
                        GoogleUserCircleAvatar(identity: user),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(user.displayName ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        const SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.mic),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "음성 - 글자",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const SendManDemo()));
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.mic),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "글자 - 음성",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TextToSpeech()));
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.image),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "사진 - 글자",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PhotoToText()));
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.attach_file),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "음성 텍스트 보기",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TtsList()));
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.attach_file),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "사진 텍스트 보기",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SttList()));
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 16, 38, 104),
                    ),
                    onPressed: () {},
                    child: const Text(
                      '로그아웃',
                      style: (TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 20)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Drawer();
    }
  }
}
