class SttPostsList {
  late final List<SttPost> posts;

  SttPostsList({required this.posts});

  factory SttPostsList.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['content'] as List;

    List<SttPost> postList = list.map((i) => SttPost.fromJson(i)).toList();

    return SttPostsList(posts: postList);
  }
}

class SttPost {
  final String text;
  final String createdDate;
  final String url;

  SttPost({required this.text, required this.createdDate, required this.url});

  factory SttPost.fromJson(Map<String, dynamic> json) {
    String text = json['text'];
    String createdDate = json['createdDate'];
    String url = json['url'];
    DateTime date = DateTime.parse(createdDate);
    String y = "${date.year}년 ";
    String m = "${date.month}월 ";
    String d = "${date.day}일 ";
    String h = "${date.hour}시 ";
    String c = "${date.minute}분";
    return SttPost(createdDate: y+m+d+h+c, text: text, url: url);

  }
}