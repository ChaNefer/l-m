import 'package:flutter/material.dart';

class LikePostButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;

  LikePostButton({required this.isLiked, required this.likeCount, required this.onLike});

  @override
  _LikePostButtonState createState() => _LikePostButtonState();
}

class _LikePostButtonState extends State<LikePostButton> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    likeCount = widget.likeCount;
  }

  void _handleLike() {
    setState(() {
      isLiked = !isLiked; // Zmieniamy stan polubienia
      likeCount = isLiked ? likeCount + 1 : likeCount - 1; // Zmieniamy liczbę polubień
    });
    widget.onLike(); // Wywołujemy akcję, gdy post jest polubiony
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
          onPressed: _handleLike,
        ),
        Text('$likeCount')
      ],
    );
  }
}



