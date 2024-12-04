import 'dart:convert';

class CommentsLocalization {
  static Map<String, dynamic> comments = {};

  static void loadCommentsJson(String jsonComments) {
    comments = jsonDecode(jsonComments)['pl']['comment'];
  }

  // static String translateComment(String commentKey) {
  //   return comments[commentKey] ?? commentKey;
  // }

  static String getCommentsCount(int count) {
    if (comments.isEmpty) {
      return '$count komentarzy';
    }
    if (count == 1) {
      return '1 ${comments['one']}';
    } else if (count % 10 == 2 || count % 10 == 3 || count % 10 == 4) {
      return '$count komentarze';
    } else {
      return '$count komentarzy';
    }
  }
}
