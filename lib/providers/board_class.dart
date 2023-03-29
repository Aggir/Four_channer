import 'package:flutter/material.dart';

class BoardClass with ChangeNotifier {
  final String tag;
  final String title;
  final bool isSafeForWork;
  final Color color;

  BoardClass(
      {required this.tag,
      required this.title,
      required this.isSafeForWork,
      required this.color});
}
