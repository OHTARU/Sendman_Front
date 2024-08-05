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
  final String text;
  final String createdDate;

  TtsPost({required this.text, required this.createdDate});

  factory TtsPost.fromJson(Map<String, dynamic> json) {
    String text = json['text'];
    String createdDate = json['createdDate'];
    DateTime date = DateTime.parse(createdDate);
    String y = "${date.year}년 ";
    String m = "${date.month}월 ";
    String d = "${date.day}일 ";
    String h = "${date.hour}시 ";
    String c = "${date.minute}분";
    return TtsPost(createdDate: y+m+d+h+c, text: text);

  }
}