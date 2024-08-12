import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GetToken {
  Future<String> readToken() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File('${dir.path}/token.txt').readAsString();
      return file;
    } catch (e) {
      print('토큰 읽기 오류: $e');
      return '';
    }
  }
}
