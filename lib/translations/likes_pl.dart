import 'dart:convert';

class LikesLocalization {
  static Map<String, dynamic> likes = {};

  static void loadLikesJson(String jsonString) {
    likes = jsonDecode(jsonString)['pl']['likes'];
  }

  static String getLikesCount(int count) {
    if (likes.isEmpty) {
      return '$count likes';
    }

    if (count == 1) {
      return '1 ${likes['one']}';
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return '$count ${likes['few']}';
    } else {
      return '$count ${likes['many']}';
    }
  }
}
