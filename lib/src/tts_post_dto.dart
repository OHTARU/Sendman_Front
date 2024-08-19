import 'package:intl/intl.dart';

class TtsPostsList {
  late final List<TtsPost> posts;

  TtsPostsList({required this.posts});

  factory TtsPostsList.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['content'] as List;

    List<TtsPost> postList = list.map((i) => TtsPost.fromJson(i)).toList();

    return TtsPostsList(posts: postList);
  }
}

class TtsPost {
  final int id;
  final String url;
  final String text;
  final String createdDate;
  final String type;

  TtsPost({required this.id,required this.url,required this.text, required this.createdDate, required this.type});

  factory TtsPost.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String text = json['text'];
    String createdDate = json['createdDate'];
    String type = json['type'];
    String url = json['url'];
    DateTime date = DateTime.parse(createdDate);
    DateFormat dateFormat = DateFormat('yy.MM.dd aa hh:mm', 'ko');
    dateFormat.format(date);
    return TtsPost(id: id,url: url,createdDate: dateFormat.toString(), text: text, type: type);

  }
}