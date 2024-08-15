import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../src/tts_post_dto.dart';
import 'package:flutter_application_1/src/get_token.dart';

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
  final GetToken _getToken = GetToken();

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

  Future<void> _fetchPage(int pageKey) async {
    try {
      String token = await _getToken.readToken();
      var url = Uri.parse("http://13.125.54.112:8080/list?page=$pageKey");

      Map<String, String> headers = {
        "Authorization": "Bearer $token",
      };

      var response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.bodyBytes.isNotEmpty) {
          Map<String, dynamic> responseList2 =
              jsonDecode(utf8.decode(response.bodyBytes));
          var result = TtsPostsList.fromJson(responseList2['data']);

          final isLastPage = responseList2['data']['totalPages'] <= pageKey;
          if (isLastPage) {
            _pagingController.appendLastPage(result.posts);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(result.posts, nextPageKey);
          }
        } else {
          _pagingController.error = "responseBody is Empty";
        }
      } else {
        _pagingController.error =
            "Failed to fetch data. Status code: ${response.statusCode}";
      }
    } catch (e) {
      _pagingController.error = e.toString();
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
        child: PagedListView<int, TtsPost>(
          pagingController: _pagingController, //저장했던 정보들
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
            )
          ],
        ),
      ),
    );
  }
}
