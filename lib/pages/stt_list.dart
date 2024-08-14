import 'dart:convert';
import 'dart:io';
//import 'dart:ui';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/app_bar.dart';
import 'package:flutter_application_1/widgets/drawer.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'stt_post_dto.dart';
//import 'tts_post_dto.dart';

class Sttlist extends StatelessWidget {
  const Sttlist({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SttList(),
    );
  }
}

class SttList extends StatefulWidget {
  const SttList({super.key});

  @override
  SttListState createState() => SttListState();
}

class SttListState extends State<SttList> {
  final PagingController<int, SttPost> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _requestPermissions();
    _pagingController.addPageRequestListener((pageKey) {
      //페이지를 가져오는 리스너
      _fetchPage(pageKey);
    });
    super.initState();
  }

  //저장 권한 받기
  void _requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print("Permission granted");
    } else {
      print("Permission denied");
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<String> _readToken() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File('${dir.path}/token.txt').readAsString();
      return file;
    } catch (e) {
      print('토큰 읽기 오류: $e');
      return '';
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      String token = await _readToken();
      var url = Uri.parse("http://13.125.54.112:8080/stt/list?page=$pageKey");

      Map<String, String> headers = {
        "Authorization": "Bearer $token",
      };

      var response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.bodyBytes.isNotEmpty) {
          Map<String, dynamic> responseList2 =
              jsonDecode(utf8.decode(response.bodyBytes));

          var result = SttPostsList.fromJson(responseList2['data']);

          final isLastPage = responseList2['data']['totalPages'] <= pageKey;

          await Future.delayed(const Duration(seconds: 2));

          if (isLastPage) {
            _pagingController.appendLastPage(result.posts);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(result.posts, nextPageKey);
          }
        } else {
          print("responsebody 비어있음");
          _pagingController.error = "responseBody is Empty";
        }
      } else {
        print("Failed to fetch data. 상태코드 : ${response.statusCode}");
        _pagingController.error =
            "Failed to fetch data. Status code: ${response.statusCode}";
      }
    } catch (e) {
      print("error --> $e");
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(appBar: AppBar(), center: true),
      drawer: const BaseDrawer(),
      body: RefreshIndicator(
        //새로고침 package안에 들어있는 키워드
        onRefresh: () =>
            Future.sync(() => _pagingController.refresh()), //새로고침시 초기화
        child: PagedListView<int, SttPost>(
          pagingController: _pagingController, //저장했던 정보들
          builderDelegate: PagedChildBuilderDelegate<SttPost>(
            itemBuilder: (context, item, index) => Padding(
              padding: const EdgeInsets.all(15.0),
              child: PostItem(item.text, item.createdDate, item.url),
            ),
          ),
        ),
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final String createDate;
  final String text;
  final String url;
  const PostItem(this.text, this.createDate, this.url, {super.key});

  Future<String> _getDownloadDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getDownloadsDirectory();
      final downloadPath = directory!.path;
      final downloadDir = Directory(downloadPath);
      print("다운로드 경로 : $downloadPath");
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      return downloadPath;
    } else {
      directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  //url를 통한 다운로드 시작
  void _startDownload(String url) async {
    final downloadDirectory = await _getDownloadDirectory();
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadDirectory,
      fileName: Uri.parse(url).pathSegments.last,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    print('Download task started with ID: $taskId');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(11),
        ),
        color: Color(0xffD9D9D9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              (text.trim().isEmpty) ? "제목 없음" : text,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(createDate,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                )),
            ElevatedButton(
              onPressed: () => _startDownload(url),
              child: const Text("다운로드"),
            )
          ],
        ),
      ),
    );
  }
}
