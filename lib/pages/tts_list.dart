import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/tts_detail.dart';
import 'dart:convert';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../src/tts_post_dto.dart';
import '../src/get_token.dart';

class TtsList extends StatefulWidget {
  const TtsList({super.key});

  @override
  TtsListState createState() => TtsListState();
}

class TtsListState extends State<TtsList> {
  final PagingController<int, TtsPost> _pagingController =
      PagingController(firstPageKey: 1);
  Future? _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _initializePage();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _initializePage() async {
    String token = await GetToken().readToken();
    await _fetchPage(1, token);
  }

  Future<void> _fetchPage(int pageKey, [String? token]) async {
    token ??= await GetToken().readToken();
    var url = Uri.parse("http://13.125.54.112:8080/list?page=$pageKey");

    Map<String, String> headers = {"Authorization": "Bearer $token"};
    var response = await http.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseList =
          jsonDecode(utf8.decode(response.bodyBytes));
      var result = TtsPostsList.fromJson(responseList['data']);
      final isLastPage = responseList['data']['totalPages'] <= pageKey;
      if (isLastPage) {
        _pagingController.appendLastPage(result.posts);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(result.posts, nextPageKey);
      }
    } else {
      _pagingController.error =
          "Failed to fetch data. Status code: ${response.statusCode}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(appBar: AppBar(), center: true),
      drawer: const BaseDrawer(),
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: PagedListView<int, TtsPost>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<TtsPost>(
                itemBuilder: (context, item, index) => PostItem(
                    item.id, item.url, item.text, item.createdDate, item.type),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class PostItem extends StatelessWidget {
  final int id;
  final String? url;
  final String text;
  final String createdDate;
  final String type;
  const PostItem(this.id, this.url, this.text, this.createdDate, this.type,
      {super.key});

  Container _iconContainer(IconData icon, Color color) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15), color: color),
      width: 70.0,
      height: 70.0,
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: ListTile(
        title: Container(
          height: 100,
          width: 100,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.grey, width: 1, style: BorderStyle.solid),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (text.trim().isEmpty) ? "제목 없음" : text,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        )
                      ],
                    ),
                  ),
                ),
                (type == 'STT')
                    ? _iconContainer(Icons.mic, Colors.amber)
                    : _iconContainer(Icons.image, Colors.red),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TtsDetail(recognizedText: text),
            ),
          );
        },
      ),
    );
  }
}
