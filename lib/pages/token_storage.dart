import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TokenStorage extends StatefulWidget {
  const TokenStorage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TokenStorage();
  }
}

class _TokenStorage extends State<TokenStorage> {
  TextEditingController controller = TextEditingController();
  String token = '';

  @override
  void initState() {
    super.initState();
    readToken();
  }

  Future<void> writeToken(String token) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/token.txt').writeAsString(token);
      print('토큰 저장 완료: $token');
    } catch (e) {
      print('토큰 저장 오류: $e');
    }
  }

  Future<void> readToken() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File('${dir.path}/token.txt').readAsString();
      setState(() {
        token = file;
      });
      print('읽어온 토큰: $file');
    } catch (e) {
      print('토큰 읽기 오류: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/token.txt').writeAsString('');
      setState(() {
        token = '';
      });
      print('토큰 삭제 완료');
    } catch (e) {
      print('토큰 삭제 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'Enter token',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    writeToken(controller.text);
                    setState(() {
                      token = controller.text;
                    });
                  },
                  child: const Text('토큰 저장'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: readToken,
                  child: const Text('토큰 읽기'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: deleteToken,
                  child: const Text('토큰 삭제'),
                ),
              ],
            ),
            Text('저장된 토큰: $token'),
          ],
        ),
      ),
    );
  }
}
