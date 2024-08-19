import 'package:flutter/material.dart';
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
  final String? url;
  final String text;
  final String createdDate;
  final String type;

  TtsPost({required this.id,required this.url,required this.text, required this.createdDate, required this.type});

  factory TtsPost.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String text = json['text'];
    String createdDate = json['createdDate'];
    String type = json['type'];
    String? url = json['url'];
    print(createdDate);
    DateTime date = DateTime.parse(createdDate);
    print(date);
    String cd = DateFormat('yy.MM.dd a h:mm').format(date);
    print(cd);

    return TtsPost(id: id, url: url,createdDate: cd, text: text, type: type);

  }
}