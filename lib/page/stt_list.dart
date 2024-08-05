import 'dart:convert';
import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
    _pagingController.addPageRequestListener((pageKey) {
      //페이지를 가져오는 리스너
      _fetchPage(pageKey);
    });
    super.initState();
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
          print('여기 오는가? : ${responseList2.toString()}');

          var result = SttPostsList.fromJson(responseList2['data']);

          final isLastPage = responseList2['data']['totalPages'] <= pageKey;

          await Future.delayed(const Duration(seconds: 1));

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        //AppBar
        title: const Text("무한 스크롤 STT"),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(100, 30, 30, 30),
      ),
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

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(url);
    }
    return Container(
      height: 300,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(11),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 158, 249),
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              createDate,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            Text(
              url,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }
}
