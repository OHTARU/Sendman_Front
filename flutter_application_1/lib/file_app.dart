import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_bar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileApp extends StatefulWidget {
  const FileApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FileApp();
  }
}

class _FileApp extends State<FileApp> {
  List<String> itemList = List.empty(growable: true);
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    readCountFile();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: '여긴 연습용',
        center: false,
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: Center(
                        child: Text(
                          itemList[index],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  },
                  itemCount: itemList.length,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print("추가된 텍스트: ${controller.text}");
                      }
                      writeTxt(controller.text);
                      setState(() {
                        itemList.add(controller.text);
                      });
                    },
                    child: const Text('추가'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      deleteFileContents();
                      setState(() {
                        itemList.clear();
                        if (kDebugMode) {
                          print('데이터삭제');
                        }
                      });
                    },
                    child: const Text('삭제'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void writeCountFile(int count) async {
    var dir = await getApplicationDocumentsDirectory();
    File('${dir.path}/txt_file1.txt').writeAsStringSync(count.toString());
  }

  void readCountFile() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File('${dir.path}/txt_file1.txt').readAsString();
      if (kDebugMode) {
        print('읽어온 파일: $file');
      }
    } catch (e) {
      if (kDebugMode) {
        print('파일 읽기 오류: $e');
      }
    }
  }

  void initData() async {
    var result = await readListFile();
    if (mounted) {
      setState(() {
        itemList.addAll(result);
      });
    }
  }

  Future<List<String>> readListFile() async {
    List<String> itemList = List.empty(growable: true);
    var key = 'first';
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? firstCheck = pref.getBool(key);
    var dir = await getApplicationDocumentsDirectory();
    bool firstExist = await File('${dir.path}/txt_file1.txt').exists();

    if (firstCheck == null || firstCheck == false || !firstExist) {
      pref.setBool(key, true);

      // Ensure context is used synchronously
      if (!mounted) return itemList;
      var file = await DefaultAssetBundle.of(context)
          .loadString('assets/txt_file1.txt');
      File('${dir.path}/txt_file1.txt').writeAsStringSync(file);

      var array = file.split('\n');
      for (var item in array) {
        if (kDebugMode) {
          print('초기 데이터: $item');
        }
        itemList.add(item);
      }
    } else {
      var file = await File('${dir.path}/txt_file1.txt').readAsString();
      var array = file.split('\n');
      for (var item in array) {
        if (kDebugMode) {
          print('기존 데이터: $item');
        }
        itemList.add(item);
      }
    }
    return itemList;
  }

  void writeTxt(String txt) async {
    var dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/txt_file1.txt');
    var existingContent = await file.readAsString();
    var newContent = '$existingContent\n$txt';
    await file.writeAsString(newContent);
  }

  void deleteFileContents() async {
    var dir = await getApplicationDocumentsDirectory();
    File('${dir.path}/txt_file1.txt').writeAsStringSync('');
  }
}
