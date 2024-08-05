import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import 'tts_post_dto.dart';

class Ttslist extends StatelessWidget {
  const Ttslist({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TtsList(),
    );
  }
}

class TtsList extends StatefulWidget {
  const TtsList({super.key});

  @override
  TtsListState createState() => TtsListState();
}

class TtsListState extends State<TtsList> {
  final PagingController<int, TtsPost> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
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
      var url = Uri.parse("http://13.125.54.112:8080/tts/list?page=$pageKey");

      Map<String, String> headers = {
        "Authorization": "Bearer $token",
      };

      var response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.bodyBytes.isNotEmpty) {
          Map<String, dynamic> responseList2 =
              jsonDecode(utf8.decode(response.bodyBytes));
          print('여기 오는가? : ${responseList2.toString()}');

          var result = TtsPostsList.fromJson(responseList2['data']);

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
        title: const Text("무한 스크롤 TTS"),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(100, 30, 30, 30),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, TtsPost>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<TtsPost>(
            itemBuilder: (context, item, index) => Padding(
              padding: const EdgeInsets.all(15.0),
              child: PostItem(item.text, item.createdDate),
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

  const PostItem(this.text, this.createDate, {super.key});

  @override
  Widget build(BuildContext context) {
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              createDate,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
